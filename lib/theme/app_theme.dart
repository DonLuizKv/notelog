import 'package:material_ui/material_ui.dart';

import 'app_palettes.dart';

/// Font families used across the app.
///
/// Headings use a serif face and body text the platform sans-serif face.
/// When bundled font files are added under assets/fonts, update [heading]
/// and [body] to the declared family names.
class AppFonts {
  AppFonts._();

  static const String heading = 'Georgia';
  static const List<String> headingFallback = ['Noto Serif', 'serif'];
  static const String? body = null;
}

/// Builds the app [ThemeData] from an [AppPalette]. Light mode only: the
/// brightness is derived from the palette background so text stays readable.
class AppTheme {
  AppTheme._();

  static ThemeData build(AppPalette palette) {
    final brightness = palette.hasDarkBackground
        ? Brightness.dark
        : Brightness.light;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: palette.foreground,
      onPrimary: palette.background,
      primaryContainer: palette.surfaceStrong,
      onPrimaryContainer: palette.foreground,
      secondary: palette.accent,
      onSecondary: palette.onAccent,
      secondaryContainer: blend(palette.accent, palette.background, 0.25),
      onSecondaryContainer: palette.foreground,
      tertiary: palette.accent,
      onTertiary: palette.onAccent,
      error: const Color(0xFFB3261E),
      onError: const Color(0xFFFFFFFF),
      surface: palette.background,
      onSurface: palette.foreground,
      onSurfaceVariant: palette.mutedForeground,
      surfaceContainerLowest: palette.background,
      surfaceContainerLow: palette.surface,
      surfaceContainer: palette.surface,
      surfaceContainerHigh: palette.surfaceStrong,
      surfaceContainerHighest: palette.surfaceStrong,
      outline: palette.outline,
      outlineVariant: blend(palette.foreground, palette.background, 0.10),
      inverseSurface: palette.foreground,
      onInverseSurface: palette.background,
      inversePrimary: palette.accent,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      dividerColor: palette.outline,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, palette),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: palette.onAccent,
        elevation: 2,
        shape: const CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceStrong,
        selectedColor: blend(palette.accent, palette.background, 0.35),
        labelStyle: TextStyle(color: palette.foreground, fontSize: 13),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, AppPalette palette) {
    final colored = base.apply(
      bodyColor: palette.foreground,
      displayColor: palette.foreground,
    );

    TextStyle? serif(TextStyle? style, {double? size}) => style?.copyWith(
      fontFamily: AppFonts.heading,
      fontFamilyFallback: AppFonts.headingFallback,
      fontSize: size,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );

    return colored.copyWith(
      displaySmall: serif(colored.displaySmall),
      headlineLarge: serif(colored.headlineLarge),
      headlineMedium: serif(colored.headlineMedium, size: 28),
      headlineSmall: serif(colored.headlineSmall, size: 24),
      titleLarge: serif(colored.titleLarge, size: 21),
      titleMedium: colored.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: colored.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: colored.bodyMedium?.copyWith(fontSize: 14.5, height: 1.45),
      bodySmall: colored.bodySmall?.copyWith(
        color: palette.mutedForeground,
        height: 1.4,
      ),
      labelSmall: colored.labelSmall?.copyWith(color: palette.mutedForeground),
    );
  }
}
