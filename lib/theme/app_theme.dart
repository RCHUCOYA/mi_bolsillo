import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color income;
  final Color expense;
  final Color warning;

  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.income,
    required this.expense,
    required this.warning,
  });

  static const light = AppPalette(
    primary: Color(0xFF5B5AF7),
    primaryDark: Color(0xFF2F46D8),
    accent: Color(0xFF12B8A6),
    background: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFEFF2F8),
    text: Color(0xFF171923),
    textMuted: Color(0xFF6B7280),
    border: Color(0xFFE2E7F0),
    income: Color(0xFF169B62),
    expense: Color(0xFFD64545),
    warning: Color(0xFFFFB547),
  );

  static const dark = AppPalette(
    primary: Color(0xFF8D8CFF),
    primaryDark: Color(0xFF5965F3),
    accent: Color(0xFF2DD4BF),
    background: Color(0xFF0F1220),
    surface: Color(0xFF181B2A),
    surfaceSoft: Color(0xFF23283A),
    text: Color(0xFFF6F7FB),
    textMuted: Color(0xFFAAB1C2),
    border: Color(0xFF2D3347),
    income: Color(0xFF4ADE80),
    expense: Color(0xFFFF6B6B),
    warning: Color(0xFFFBBF24),
  );

  LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryDark,
    Color? accent,
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? text,
    Color? textMuted,
    Color? border,
    Color? income,
    Color? expense,
    Color? warning,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

class AppColors {
  static const Color primary = Color(0xFF5B5AF7);
  static const Color primaryDark = Color(0xFF2F46D8);
  static const Color accent = Color(0xFF12B8A6);
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFEFF2F8);
  static const Color text = Color(0xFF171923);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE2E7F0);
  static const Color income = Color(0xFF169B62);
  static const Color expense = Color(0xFFD64545);
  static const Color warning = Color(0xFFFFB547);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  static List<BoxShadow> soft([Color color = const Color(0xFF111827)]) => [
    BoxShadow(
      color: color.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

extension AppThemeContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;

  List<BoxShadow> softShadow([Color? color]) => [
    BoxShadow(
      color: (color ?? colors.text).withValues(
        alpha: Theme.of(this).brightness == Brightness.dark ? 0.22 : 0.08,
      ),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

class MiBolsilloTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: brightness,
      primary: palette.primary,
      secondary: palette.accent,
      surface: palette.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      fontFamily: 'Roboto',
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.expense),
        ),
        hintStyle: TextStyle(color: palette.textMuted, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.text,
        contentTextStyle: TextStyle(color: palette.background),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
