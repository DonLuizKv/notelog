import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:notelog/theme/app_palettes.dart';
import 'package:notelog/theme/app_theme.dart';

void main() {
  group('AppPalettes', () {
    test('has the three palettes with the given 60/30/10 colours', () {
      expect(AppPalettes.all, hasLength(3));
      expect(AppPalettes.principal.background, const Color(0xFFF2E8DA));
      expect(AppPalettes.principal.foreground, const Color(0xFF3B2418));
      expect(AppPalettes.principal.accent, const Color(0xFF8EC5FF));
      expect(AppPalettes.paleta1.background, const Color(0xFF012A23));
      expect(AppPalettes.paleta1.foreground, const Color(0xFFF9EFDB));
      expect(AppPalettes.paleta1.accent, const Color(0xFFC12589));
      expect(AppPalettes.paleta2.background, const Color(0xFF012438));
      expect(AppPalettes.paleta2.foreground, const Color(0xFFDBF4FC));
      expect(AppPalettes.paleta2.accent, const Color(0xFFF16F1B));
    });

    test('byId falls back to the default palette', () {
      expect(AppPalettes.byId('paleta2'), AppPalettes.paleta2);
      expect(AppPalettes.byId('desconocida'), AppPalettes.principal);
      expect(AppPalettes.byId(null), AppPalettes.principal);
    });

    for (final palette in AppPalettes.all) {
      test('${palette.name} keeps text readable (WCAG AA)', () {
        expect(
          contrastRatio(palette.foreground, palette.background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(palette.mutedForeground, palette.background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(palette.foreground, palette.surfaceStrong),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(palette.onAccent, palette.accent),
          greaterThanOrEqualTo(4.5),
        );
      });
    }

    test('onAccent picks the more contrasting colour', () {
      // Light blue accent needs the dark brown text.
      expect(AppPalettes.principal.onAccent, const Color(0xFF3B2418));
      // Orange accent reads better with the dark background colour.
      expect(AppPalettes.paleta2.onAccent, const Color(0xFF012438));
    });
  });

  group('AppTheme', () {
    test('builds ThemeData from the palette', () {
      final theme = AppTheme.build(AppPalettes.principal);
      expect(theme.scaffoldBackgroundColor, AppPalettes.principal.background);
      expect(theme.colorScheme.surface, AppPalettes.principal.background);
      expect(theme.colorScheme.onSurface, AppPalettes.principal.foreground);
      expect(theme.colorScheme.secondary, AppPalettes.principal.accent);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        AppPalettes.principal.accent,
      );
    });

    test('switching palette changes the theme colours', () {
      final principal = AppTheme.build(AppPalettes.principal);
      final paleta1 = AppTheme.build(AppPalettes.paleta1);
      expect(
        paleta1.scaffoldBackgroundColor,
        isNot(principal.scaffoldBackgroundColor),
      );
      expect(paleta1.colorScheme.onSurface, AppPalettes.paleta1.foreground);
      // Dark backgrounds get a dark brightness so default text is light.
      expect(paleta1.colorScheme.brightness, Brightness.dark);
    });
  });
}
