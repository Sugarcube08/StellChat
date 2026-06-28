import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../design_system/animations.dart';

class StellColorsExtension extends ThemeExtension<StellColorsExtension> {
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color borderPrimary;
  final Color borderMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color accent;

  const StellColorsExtension({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.borderPrimary,
    required this.borderMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.accent,
  });

  // Legacy compatibility getters mapping to semantic tokens
  Color get primaryBackground => backgroundPrimary;
  Color get secondaryBackground => backgroundSecondary;
  Color get elevatedSurface => surfacePrimary;
  Color get hairline => borderPrimary;
  Color get primaryText => textPrimary;
  Color get secondaryText => textSecondary;
  Color get stellAccent => accent;

  @override
  ThemeExtension<StellColorsExtension> copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? borderPrimary,
    Color? borderMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? accent,
  }) {
    return StellColorsExtension(
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderMuted: borderMuted ?? this.borderMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      accent: accent ?? this.accent,
    );
  }

  @override
  ThemeExtension<StellColorsExtension> lerp(
    ThemeExtension<StellColorsExtension>? other,
    double t,
  ) {
    if (other is! StellColorsExtension) {
      return this;
    }
    return StellColorsExtension(
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      borderMuted: Color.lerp(borderMuted, other.borderMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

class StellTheme {
  static const darkColors = StellColorsExtension(
    backgroundPrimary: Color(0xFF090B12),
    backgroundSecondary: Color(0xFF10131C),
    surfacePrimary: Color(0xFF10131C),
    surfaceSecondary: Color(0xFF151A24),
    borderPrimary: Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
    borderMuted: Color(0x0AFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFAEB7C6),
    textMuted: Color(0xFF70798B),
    success: Color(0xFF00D68F),
    warning: Color(0xFFF5A524),
    error: Color(0xFFFF5C7A),
    info: Color(0xFF35B7FF),
    accent: Color(0xFF6C4DFF),
  );

  static const lightColors = StellColorsExtension(
    backgroundPrimary: Color(0xFFF7F8FA),
    backgroundSecondary: Color(0xFFFFFFFF),
    surfacePrimary: Color(0xFFECEFF3),
    surfaceSecondary: Color(0xFFE2E6EC),
    borderPrimary: Color(0x12000000),
    borderMuted: Color(0x06000000),
    textPrimary: Color(0xFF090B12),
    textSecondary: Color(0xFF6C7685),
    textMuted: Color(0xFF8C96A5),
    success: Color(0xFF00B87C),
    warning: Color(0xFFD98A1E),
    error: Color(0xFFE53935),
    info: Color(0xFF269BE6),
    accent: Color(0xFF5B3DF5),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkColors.backgroundPrimary,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: StellPageTransitionsBuilder(),
        TargetPlatform.iOS: StellPageTransitionsBuilder(),
        TargetPlatform.linux: StellPageTransitionsBuilder(),
        TargetPlatform.macOS: StellPageTransitionsBuilder(),
        TargetPlatform.windows: StellPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkColors.backgroundPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(color: darkColors.textPrimary),
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: darkColors.accent,
      onPrimary: const Color(0xFFFFFFFF),
      secondary: darkColors.surfaceSecondary,
      onSecondary: darkColors.textPrimary,
      error: darkColors.error,
      onError: const Color(0xFFFFFFFF),
      surface: darkColors.backgroundSecondary,
      onSurface: darkColors.textPrimary,
    ),
    extensions: const [darkColors],
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightColors.backgroundPrimary,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: StellPageTransitionsBuilder(),
        TargetPlatform.iOS: StellPageTransitionsBuilder(),
        TargetPlatform.linux: StellPageTransitionsBuilder(),
        TargetPlatform.macOS: StellPageTransitionsBuilder(),
        TargetPlatform.windows: StellPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightColors.backgroundPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: lightColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(color: lightColors.textPrimary),
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: lightColors.accent,
      onPrimary: const Color(0xFFFFFFFF),
      secondary: lightColors.surfaceSecondary,
      onSecondary: lightColors.textPrimary,
      error: lightColors.error,
      onError: const Color(0xFFFFFFFF),
      surface: lightColors.backgroundSecondary,
      onSurface: lightColors.textPrimary,
    ),
    extensions: const [lightColors],
  );
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _boxName = 'theme_settings';
  static const String _key = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final box = await Hive.openBox(_boxName);
      final stored = box.get(_key, defaultValue: 'system') as String;
      switch (stored) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_key, mode.name);
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
