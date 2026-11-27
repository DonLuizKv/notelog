import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notelog/providers/notes_provider.dart';
import 'package:notelog/providers/settings_provider.dart';
import 'package:notelog/services/delta_text.dart';
import 'package:notelog/services/storage_service.dart';
import 'package:notelog/theme/app_palettes.dart';

void main() {
  late Directory tempDir;

  StorageService newStorage() =>
      StorageService(directoryProvider: () async => tempDir);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notelog_provider_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('notes persist, sort pinned first and are searchable', () async {
    var tick = 0;
    final provider = NotesProvider(
      newStorage(),
      clock: () => DateTime(2026, 1, 1).add(Duration(minutes: tick++)),
    );
    await provider.load();

    final anime = await provider.createCollection('Anime');
    final first = await provider.createNote(
      title: 'Mi lista de animes',
      content: deltaFromPlainText('Frieren completado'),
      collectionId: anime.id,
    );
    await provider.createNote(title: 'Notas de estudio');
    await provider.togglePin(first.id);

    final reloaded = NotesProvider(newStorage());
    await reloaded.load();
    expect(reloaded.notes.map((n) => n.title).toList(), [
      'Mi lista de animes',
      'Notas de estudio',
    ]);
    expect(reloaded.notes.first.pinned, isTrue);
    expect(reloaded.search('frieren').single.id, first.id);
    expect(reloaded.search('', collectionId: anime.id).single.id, first.id);
    expect(reloaded.collections.single.name, 'Anime');
  });

  test('delete can be undone and deleting a collection keeps notes', () async {
    final provider = NotesProvider(newStorage());
    await provider.load();
    final collection = await provider.createCollection('Ideas');
    final note = await provider.createNote(
      title: 'Ideas de proyectos',
      collectionId: collection.id,
    );

    final deleted = await provider.deleteNote(note.id);
    expect(provider.notes, isEmpty);
    await provider.restoreNote(deleted!);
    expect(provider.notes.single.id, note.id);

    await provider.deleteCollection(collection.id);
    expect(provider.collections, isEmpty);
    expect(provider.notes.single.collectionId, isNull);
  });

  test('settings provider persists name and palette', () async {
    final settings = SettingsProvider(newStorage());
    await settings.load();
    expect(settings.isFirstRun, isTrue);
    expect(settings.palette, AppPalettes.principal);

    await settings.setUserName('  Amber ');
    await settings.setPalette('paleta2');

    final reloaded = SettingsProvider(newStorage());
    await reloaded.load();
    expect(reloaded.userName, 'Amber');
    expect(reloaded.isFirstRun, isFalse);
    expect(reloaded.palette, AppPalettes.paleta2);
    expect(() => reloaded.setUserName('  '), throwsArgumentError);
  });

  test('plainTextOf reads Quill delta JSON', () {
    expect(
      plainTextOf('[{"insert":"Hola "},{"insert":"mundo\\n"}]'),
      'Hola mundo',
    );
    expect(plainTextOf('texto plano'), 'texto plano');
  });
}
