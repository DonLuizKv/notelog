/// User preferences stored on the device.
class AppSettings {
  const AppSettings({
    this.userName = '',
    this.paletteId = 'principal',
    this.homeBackgroundPath,
  });

  /// Asset used as home background when the user has not picked one.
  static const String defaultHomeBackgroundAsset =
      'assets/images/home_background.jpg';

  final String userName;
  final String paletteId;

  /// Local file path of a custom home background, or null for the default
  /// asset [defaultHomeBackgroundAsset].
  final String? homeBackgroundPath;

  /// True until the user has entered a name in the onboarding screen.
  bool get isFirstRun => userName.trim().isEmpty;

  bool get usesDefaultBackground => homeBackgroundPath == null;

  AppSettings copyWith({
    String? userName,
    String? paletteId,
    String? homeBackgroundPath,
    bool resetHomeBackground = false,
  }) {
    return AppSettings(
      userName: userName ?? this.userName,
      paletteId: paletteId ?? this.paletteId,
      homeBackgroundPath: resetHomeBackground
          ? null
          : (homeBackgroundPath ?? this.homeBackgroundPath),
    );
  }

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'paletteId': paletteId,
    'homeBackgroundPath': homeBackgroundPath,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      userName: json['userName'] as String? ?? '',
      paletteId: json['paletteId'] as String? ?? 'principal',
      homeBackgroundPath: json['homeBackgroundPath'] as String?,
    );
  }
}
