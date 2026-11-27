import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'providers/notes_provider.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es';
  await initializeDateFormatting('es');

  final storage = StorageService();
  final settings = SettingsProvider(storage);
  final notes = NotesProvider(storage);
  await Future.wait([settings.load(), notes.load()]);

  runApp(NotelogApp(settings: settings, notes: notes));
}
