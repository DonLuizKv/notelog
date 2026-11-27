import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/collection.dart';
import '../models/note.dart';
import '../models/note_version.dart';
import '../services/delta_text.dart';
import '../services/storage_service.dart';

/// Notes, collections and versions, persisted on every change.
class NotesProvider extends ChangeNotifier {
  NotesProvider(this._storage, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final StorageService _storage;
  final DateTime Function() _clock;
  final Uuid _uuid = const Uuid();

  List<Note> _notes = [];
  List<NoteVersion> _versions = [];
  List<Collection> _collections = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Notes sorted with pinned first, then most recently edited.
  List<Note> get notes => List.unmodifiable(_sorted(_notes));

  List<Collection> get collections => List.unmodifiable(_collections);

  List<NoteVersion> get allVersions => List.unmodifiable(_versions);

  Future<void> load() async {
    final data = await _storage.loadNotesData();
    _notes = [...data.notes];
    _versions = [...data.versions];
    _collections = [...data.collections];
    _loaded = true;
    notifyListeners();
  }

  // Notes

  Note? noteById(String id) {
    for (final note in _notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  Future<Note> createNote({
    String title = '',
    String content = Note.emptyContent,
    String? coverImagePath,
    String? collectionId,
    int? color,
  }) async {
    final now = _clock();
    final note = Note(
      id: _uuid.v4(),
      title: title.trim(),
      content: content,
      coverImagePath: coverImagePath,
      collectionId: collectionId,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
    _notes.add(note);
    await _persist();
    return note;
  }

  /// Replaces the stored note with [note] and refreshes its edit time.
  Future<Note> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) throw StateError('Nota no encontrada: ${note.id}');
    final updated = note.copyWith(updatedAt: _clock());
    _notes[index] = updated;
    await _persist();
    return updated;
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notes[index] = _notes[index].copyWith(pinned: !_notes[index].pinned);
    await _persist();
  }

  /// Deletes a note and its versions. Returns the removed note so the UI can
  /// offer undo through [restoreNote].
  Future<DeletedNote?> deleteNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return null;
    final note = _notes.removeAt(index);
    final versions = _versions.where((v) => v.noteId == id).toList();
    _versions.removeWhere((v) => v.noteId == id);
    await _persist();
    return DeletedNote(note, versions);
  }

  Future<void> restoreNote(DeletedNote deleted) async {
    if (noteById(deleted.note.id) != null) return;
    _notes.add(deleted.note);
    _versions.addAll(deleted.versions);
    await _persist();
  }

  /// Case-insensitive search on title and plain text content, optionally
  /// restricted to a collection.
  List<Note> search(String query, {String? collectionId}) {
    final q = query.trim().toLowerCase();
    final result = _notes.where((note) {
      if (collectionId != null && note.collectionId != collectionId) {
        return false;
      }
      if (q.isEmpty) return true;
      return note.title.toLowerCase().contains(q) ||
          plainTextOf(note.content).toLowerCase().contains(q);
    }).toList();
    return _sorted(result);
  }

  List<Note> notesInCollection(String collectionId) =>
      _sorted(_notes.where((n) => n.collectionId == collectionId).toList());

  // Collections

  Collection? collectionById(String? id) {
    if (id == null) return null;
    for (final collection in _collections) {
      if (collection.id == id) return collection;
    }
    return null;
  }

  Future<Collection> createCollection(String name, {int? color}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'El nombre no puede estar vacío');
    }
    final collection = Collection(
      id: _uuid.v4(),
      name: trimmed,
      color: color,
      createdAt: _clock(),
    );
    _collections.add(collection);
    await _persist();
    return collection;
  }

  Future<void> renameCollection(String id, String name) async {
    final trimmed = name.trim();
    final index = _collections.indexWhere((c) => c.id == id);
    if (index == -1 || trimmed.isEmpty) return;
    _collections[index] = _collections[index].copyWith(name: trimmed);
    await _persist();
  }

  /// Deletes a collection; its notes are kept without a collection.
  Future<void> deleteCollection(String id) async {
    _collections.removeWhere((c) => c.id == id);
    for (var i = 0; i < _notes.length; i++) {
      if (_notes[i].collectionId == id) {
        _notes[i] = _notes[i].copyWith(clearCollection: true);
      }
    }
    await _persist();
  }

  Future<void> setNoteCollection(String noteId, String? collectionId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;
    _notes[index] = collectionId == null
        ? _notes[index].copyWith(clearCollection: true)
        : _notes[index].copyWith(collectionId: collectionId);
    await _persist();
  }

  // Versions (read access; versioning workflow lives in a later feature)

  /// Versions of a note, newest first.
  List<NoteVersion> versionsFor(String noteId) {
    final list = _versions.where((v) => v.noteId == noteId).toList()
      ..sort((a, b) => b.number.compareTo(a.number));
    return list;
  }

  // Data management

  Future<void> clearAll() async {
    await _storage.clearAll();
    _notes = [];
    _versions = [];
    _collections = [];
    notifyListeners();
  }

  // Internals

  Future<void> _persist() async {
    notifyListeners();
    await _storage.saveNotesData(
      NotesData(notes: _notes, versions: _versions, collections: _collections),
    );
  }

  List<Note> _sorted(List<Note> list) {
    return [...list]..sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }
}

/// A deleted note together with its versions, kept for undo.
class DeletedNote {
  const DeletedNote(this.note, this.versions);

  final Note note;
  final List<NoteVersion> versions;
}
