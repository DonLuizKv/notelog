import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:notelog/app.dart';
import 'package:notelog/models/app_settings.dart';
import 'package:notelog/providers/notes_provider.dart';
import 'package:notelog/providers/settings_provider.dart';
import 'package:notelog/screens/main_shell.dart';
import 'package:notelog/screens/onboarding_screen.dart';
import 'package:notelog/services/storage_service.dart';
import 'package:notelog/theme/app_palettes.dart';
import 'package:notelog/widgets/notelog_bottom_bar.dart';

void main() {
  late Directory tempDir;
  late StorageService storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notelog_widget_');
    storage = StorageService(directoryProvider: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<NotelogApp> buildApp(WidgetTester tester) async {
    final settings = SettingsProvider(storage);
    final notes = NotesProvider(storage);
    await tester.runAsync(() => Future.wait([settings.load(), notes.load()]));
    return NotelogApp(settings: settings, notes: notes);
  }

  testWidgets('first run shows the onboarding screen', (tester) async {
    await tester.pumpWidget(await buildApp(tester));
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
  });

  testWidgets('shell shows bottom navigation with the default palette', (
    tester,
  ) async {
    await tester.runAsync(
      () => storage.saveSettings(const AppSettings(userName: 'Amber')),
    );
    await tester.pumpWidget(await buildApp(tester));
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    Finder navLabel(String label) => find.descendant(
      of: find.byType(NotelogBottomBar),
      matching: find.text(label),
    );
    for (final label in ['Inicio', 'Historial', 'Colecciones', 'Ajustes']) {
      expect(navLabel(label), findsOneWidget);
    }
    expect(find.byTooltip('Nueva nota'), findsOneWidget);

    final context = tester.element(find.byType(MainShell));
    expect(
      Theme.of(context).scaffoldBackgroundColor,
      AppPalettes.principal.background,
    );

    await tester.tap(navLabel('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes'), findsNWidgets(2));
  });
}
