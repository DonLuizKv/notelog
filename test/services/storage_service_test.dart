import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notelog/models/app_settings.dart';
import 'package:notelog/models/collection.dart';
import 'package:notelog/models/note.dart';
import 'package:notelog/models/note_version.dart';
import 'package:notelog/services/storage_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late StorageService storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notelog_test_');
    storage = StorageService(directoryProvider: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('returns defaults when nothing is stored', () async {
    final settings = await storage.loadSettings();
    expect(settings.isFirstRun, isTrue);
    expect(settings.paletteId, 'principal');
    expect(settings.usesDefaultBackground, isTrue);
    final data = await storage.loadNotesData();
    expect(data.notes, isEmpty);
  });

  test('settings round-trip', () async {
    await storage.saveSettings(
      const AppSettings(
        userName: 'Amber',
        paletteId: 'paleta1',
        homeBackgroundPath: '/tmp/fondo.jpg',
      ),
    );
    final reloaded = await StorageService(
      directoryProvider: () async => tempDir,
    ).loadSettings();
    expect(reloaded.userName, 'Amber');
    expect(reloaded.paletteId, 'paleta1');
    expect(reloaded.homeBackgroundPath, '/tmp/fondo.jpg');
    expect(reloaded.isFirstRun, isFalse);
  });

  test('notes, versions and collections round-trip', () async {
    final created = DateTime(2026, 11, 21, 9, 20);
    final data = NotesData(
      notes: [
        Note(
          id: 'n1',
          title: 'Mi lista de animes',
          content: '[{"insert":"Frieren\\n"}]',
          collectionId: 'c1',
          color: 0xFF8EC5FF,
          pinned: true,
          createdAt: created,
          updatedAt: created,
          attachmentPaths: const ['/a.png'],
        ),
      ],
      versions: [
        NoteVersion(
          id: 'v1',
          noteId: 'n1',
          number: 1,
          label: 'Versión inicial',
          title: 'Mi lista de animes',
          content: '[{"insert":"\\n"}]',
          createdAt: created,
        ),
      ],
      collections: [Collection(id: 'c1', name: 'Anime', createdAt: created)],
    );

    await storage.saveNotesData(data);
    final reloaded = await StorageService(
      directoryProvider: () async => tempDir,
    ).loadNotesData();

    final note = reloaded.notes.single;
    expect(note.title, 'Mi lista de animes');
    expect(note.content, '[{"insert":"Frieren\\n"}]');
    expect(note.collectionId, 'c1');
    expect(note.color, 0xFF8EC5FF);
    expect(note.pinned, isTrue);
    expect(note.coverImagePath, isNull);
    expect(note.createdAt, created);
    expect(note.attachmentPaths, ['/a.png']);
    expect(reloaded.versions.single.number, 1);
    expect(reloaded.versions.single.label, 'Versión inicial');
    expect(reloaded.collections.single.name, 'Anime');
  });

  test('corrupt file falls back to defaults', () async {
    final base = await storage.baseDirectory;
    await File(p.join(base.path, StorageService.notesFileName))
        .writeAsString('{no es json');
    final data = await storage.loadNotesData();
    expect(data.notes, isEmpty);
  });

  test('importImage copies the file into app storage', () async {
    final source = File(p.join(tempDir.path, 'foto.JPG'));
    await source.writeAsBytes([1, 2, 3]);

    final stored = await storage.importImage(source.path);
    await source.delete();

    final base = await storage.baseDirectory;
    expect(p.isWithin(base.path, stored), isTrue);
    expect(p.extension(stored), '.jpg');
    expect(await File(stored).readAsBytes(), [1, 2, 3]);

    await storage.deleteManagedFile(stored);
    expect(await File(stored).exists(), isFalse);
  });

  test('deleteManagedFile ignores files outside app storage', () async {
    final outside = File(p.join(tempDir.path, 'externo.txt'));
    await outside.writeAsString('x');
    await storage.deleteManagedFile(outside.path);
    expect(await outside.exists(), isTrue);
  });
}
