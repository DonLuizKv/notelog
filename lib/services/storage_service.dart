import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/app_settings.dart';
import '../models/collection.dart';
import '../models/note.dart';
import '../models/note_version.dart';

/// Everything related to notes that is persisted together.
class NotesData {
  const NotesData({
    this.notes = const [],
    this.versions = const [],
    this.collections = const [],
  });

  final List<Note> notes;
  final List<NoteVersion> versions;
  final List<Collection> collections;

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'notes': notes.map((n) => n.toJson()).toList(),
    'versions': versions.map((v) => v.toJson()).toList(),
    'collections': collections.map((c) => c.toJson()).toList(),
  };

  factory NotesData.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) =>
        (json[key] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    return NotesData(
      notes: list('notes').map(Note.fromJson).toList(),
      versions: list('versions').map(NoteVersion.fromJson).toList(),
      collections: list('collections').map(Collection.fromJson).toList(),
    );
  }
}

/// Persists app data as JSON files inside the app documents directory.
/// Nothing leaves the device.
class StorageService {
  StorageService({Future<Directory> Function()? directoryProvider})
    : _directoryProvider =
          directoryProvider ?? getApplicationDocumentsDirectory;

  static const String settingsFileName = 'settings.json';
  static const String notesFileName = 'notes.json';
  static const String imagesDirName = 'images';

  final Future<Directory> Function() _directoryProvider;
  final Uuid _uuid = const Uuid();
  Directory? _baseDir;
  Future<void> _writeQueue = Future.value();

  Future<Directory> get baseDirectory async {
    final existing = _baseDir;
    if (existing != null) return existing;
    final root = await _directoryProvider();
    final dir = Directory(p.join(root.path, 'notelog'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return _baseDir = dir;
  }

  Future<Directory> get imagesDirectory async {
    final base = await baseDirectory;
    final dir = Directory(p.join(base.path, imagesDirName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // Settings

  Future<AppSettings> loadSettings() async {
    final json = await _readJson(settingsFileName);
    return json == null ? const AppSettings() : AppSettings.fromJson(json);
  }

  Future<void> saveSettings(AppSettings settings) =>
      _writeJson(settingsFileName, settings.toJson());

  // Notes, versions and collections

  Future<NotesData> loadNotesData() async {
    final json = await _readJson(notesFileName);
    return json == null ? const NotesData() : NotesData.fromJson(json);
  }

  Future<void> saveNotesData(NotesData data) =>
      _writeJson(notesFileName, data.toJson());

  // Images

  /// Copies an image picked by the user into app storage and returns the
  /// new path, so the note keeps working if the original file is removed.
  Future<String> importImage(String sourcePath) async {
    final dir = await imagesDirectory;
    final extension = p.extension(sourcePath).toLowerCase();
    final target = p.join(
      dir.path,
      '${_uuid.v4()}${extension.isEmpty ? '.jpg' : extension}',
    );
    await File(sourcePath).copy(target);
    return target;
  }

  /// Stores raw image bytes (for example a drawing exported as PNG).
  Future<String> saveImageBytes(
    List<int> bytes, {
    String extension = 'png',
  }) async {
    final dir = await imagesDirectory;
    final target = p.join(dir.path, '${_uuid.v4()}.$extension');
    await File(target).writeAsBytes(bytes, flush: true);
    return target;
  }

  /// Deletes a file only if it lives inside the app storage directory.
  Future<void> deleteManagedFile(String path) async {
    final base = await baseDirectory;
    if (!p.isWithin(base.path, p.normalize(path))) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// Removes all stored data and images.
  Future<void> clearAll() async {
    await _writeQueue;
    final base = await baseDirectory;
    if (await base.exists()) await base.delete(recursive: true);
    _baseDir = null;
  }

  // Internals

  Future<Map<String, dynamic>?> _readJson(String fileName) async {
    await _writeQueue;
    final base = await baseDirectory;
    final file = File(p.join(base.path, fileName));
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      // Keep the unreadable file for manual recovery and start fresh.
      await file.rename('${file.path}.corrupt');
      return null;
    }
  }

  /// Writes atomically (temp file + rename) and serialises concurrent writes.
  Future<void> _writeJson(String fileName, Map<String, dynamic> json) {
    final next = _writeQueue.then((_) async {
      final base = await baseDirectory;
      final target = File(p.join(base.path, fileName));
      final temp = File('${target.path}.tmp');
      await temp.writeAsString(jsonEncode(json), flush: true);
      await temp.rename(target.path);
    });
    _writeQueue = next.catchError((Object _) {});
    return next;
  }
}
