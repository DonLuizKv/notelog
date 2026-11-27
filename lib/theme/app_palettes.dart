import 'dart:ui' show Color;

/// A colour palette following the 60/30/10 rule.
///
/// * [background] (60 %) fills screens.
/// * [foreground] (30 %) is used for text, icons and secondary surfaces.
/// * [accent] (10 %) highlights actions such as the FAB or selected items.
class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.background,
    required this.foreground,
    required this.accent,
  });

  final String id;
  final String name;
  final Color background;
  final Color foreground;
  final Color accent;

  /// True when the background is dark enough to need light text.
  bool get hasDarkBackground => background.computeLuminance() < 0.4;

  /// Colour for text and icons drawn on top of [accent].
  ///
  /// Picks whichever of [foreground] and [background] contrasts more with
  /// the accent, so it stays readable on every palette.
  Color get onAccent => bestContrast(accent, [foreground, background]);

  /// Slightly raised surface (cards, sheets) derived from the background.
  Color get surface => blend(foreground, background, 0.05);

  /// A more prominent surface, used for chips and inputs.
  Color get surfaceStrong => blend(foreground, background, 0.10);

  /// Muted text colour for secondary information.
  Color get mutedForeground => blend(background, foreground, 0.30);

  /// Thin borders and dividers.
  Color get outline => blend(foreground, background, 0.18);
}

/// The palettes available in the app. The first one is the default.
class AppPalettes {
  AppPalettes._();

  static const AppPalette principal = AppPalette(
    id: 'principal',
    name: 'Principal',
    background: Color(0xFFF2E8DA),
    foreground: Color(0xFF3B2418),
    accent: Color(0xFF8EC5FF),
  );

  static const AppPalette paleta1 = AppPalette(
    id: 'paleta1',
    name: 'Paleta 1',
    background: Color(0xFF012A23),
    foreground: Color(0xFFF9EFDB),
    accent: Color(0xFFC12589),
  );

  static const AppPalette paleta2 = AppPalette(
    id: 'paleta2',
    name: 'Paleta 2',
    background: Color(0xFF012438),
    foreground: Color(0xFFDBF4FC),
    accent: Color(0xFFF16F1B),
  );

  static const List<AppPalette> all = [principal, paleta1, paleta2];

  static AppPalette get defaultPalette => principal;

  /// Returns the palette with [id], or the default palette when unknown.
  static AppPalette byId(String? id) {
    for (final palette in all) {
      if (palette.id == id) return palette;
    }
    return defaultPalette;
  }
}

/// WCAG contrast ratio between two colours (1.0 to 21.0).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Returns the candidate with the highest contrast against [base].
Color bestContrast(Color base, List<Color> candidates) {
  var best = candidates.first;
  var bestRatio = contrastRatio(base, best);
  for (final candidate in candidates.skip(1)) {
    final ratio = contrastRatio(base, candidate);
    if (ratio > bestRatio) {
      best = candidate;
      bestRatio = ratio;
    }
  }
  return best;
}

/// Mixes [top] over [bottom] with the given [amount] (0.0 to 1.0).
Color blend(Color top, Color bottom, double amount) {
  return Color.lerp(bottom, top, amount)!;
}
