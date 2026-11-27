import 'package:material_ui/material_ui.dart';

import '../widgets/notelog_bottom_bar.dart';
import 'placeholder_screen.dart';

/// Main scaffold with the bottom navigation: Inicio, Historial, "+",
/// Colecciones and Ajustes.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const List<NotelogNavItem> navItems = [
    NotelogNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Inicio',
    ),
    NotelogNavItem(
      icon: Icons.history_rounded,
      selectedIcon: Icons.history_rounded,
      label: 'Historial',
    ),
    NotelogNavItem(
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder_rounded,
      label: 'Colecciones',
    ),
    NotelogNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Ajustes',
    ),
  ];

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Tabs are replaced by the real screens in later features.
  static const List<Widget> _tabs = [
    PlaceholderScreen(title: 'Inicio', icon: Icons.home_rounded),
    PlaceholderScreen(title: 'Historial', icon: Icons.history_rounded),
    PlaceholderScreen(title: 'Colecciones', icon: Icons.folder_rounded),
    PlaceholderScreen(title: 'Ajustes', icon: Icons.settings_rounded),
  ];

  void _onNewNote() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('El editor de notas llegará pronto')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva nota',
        onPressed: _onNewNote,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      bottomNavigationBar: NotelogBottomBar(
        items: MainShell.navItems,
        currentIndex: _index,
        onSelected: (index) => setState(() => _index = index),
      ),
    );
  }
}
