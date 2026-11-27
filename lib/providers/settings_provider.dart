import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../theme/app_palettes.dart';

/// Holds user preferences and persists every change.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage);

  final StorageService _storage;
  AppSettings _settings = const AppSettings();
  bool _loaded = false;

  AppSettings get settings => _settings;
  bool get isLoaded => _loaded;
  bool get isFirstRun => _settings.isFirstRun;
  String get userName => _settings.userName;
  AppPalette get palette => AppPalettes.byId(_settings.paletteId);
  String? get homeBackgroundPath => _settings.homeBackgroundPath;

  Future<void> load() async {
    _settings = await _storage.loadSettings();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'El nombre no puede estar vacío');
    }
    await _update(_settings.copyWith(userName: trimmed));
  }

  Future<void> setPalette(String paletteId) async {
    await _update(
      _settings.copyWith(paletteId: AppPalettes.byId(paletteId).id),
    );
  }

  /// Copies [sourcePath] into app storage and uses it as home background.
  Future<void> setHomeBackground(String sourcePath) async {
    final previous = _settings.homeBackgroundPath;
    final stored = await _storage.importImage(sourcePath);
    await _update(_settings.copyWith(homeBackgroundPath: stored));
    if (previous != null) await _storage.deleteManagedFile(previous);
  }

  Future<void> resetHomeBackground() async {
    final previous = _settings.homeBackgroundPath;
    await _update(_settings.copyWith(resetHomeBackground: true));
    if (previous != null) await _storage.deleteManagedFile(previous);
  }

  /// Restores defaults in memory (used after deleting all data).
  void resetInMemory() {
    _settings = const AppSettings();
    notifyListeners();
  }

  Future<void> _update(AppSettings next) async {
    _settings = next;
    notifyListeners();
    await _storage.saveSettings(next);
  }
}
