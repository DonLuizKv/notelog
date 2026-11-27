import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'providers/notes_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

/// Root widget: provides state, applies the selected palette and decides
/// between onboarding (first run) and the main shell.
class NotelogApp extends StatelessWidget {
  const NotelogApp({super.key, required this.settings, required this.notes});

  final SettingsProvider settings;
  final NotesProvider notes;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<NotesProvider>.value(value: notes),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Notelog',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(settings.palette),
          themeMode: ThemeMode.light,
          locale: const Locale('es'),
          supportedLocales: const [Locale('es')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: settings.isFirstRun
              ? const OnboardingScreen()
              : const MainShell(),
        ),
      ),
    );
  }
}
