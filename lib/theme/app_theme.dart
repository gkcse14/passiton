import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Shared design tokens for every screen in light and dark mode.

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF345B49);
  static const Color primaryContainer = Color(0xFFE9EFE4);
  static const Color secondary = Color(0xFF51664A);
  static const Color secondaryContainer = Color(0xFFE8F5EF);

  // Semantic colors
  static const Color success = Color(0xFF2D7A4F);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFB91C1C);

  // Light surfaces
  static const Color backgroundLight = Color(0xFFFAF9F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE6E8E3);
  static const Color textPrimaryLight = Color(0xFF263F36);
  static const Color textSecondaryLight = Color(0xFF657167);

  // Dark surfaces
  static const Color backgroundDark = Color(0xFF111B17);
  static const Color surfaceDark = Color(0xFF1D2A24);
  static const Color borderDark = Color(0xFF33443B);
  static const Color textPrimaryDark = Color(0xFFF3F5F1);
  static const Color textSecondaryDark = Color(0xFFA8B5AC);
  static const Color primaryDark = Color(0xFFB6D4BC);

  // Object artwork accent colors
  static const Color potatoAccent = Color(0xFFD4A853);
  static const Color heartAccent = Color(0xFFE87070);
  static const Color lotusAccent = Color(0xFFB87DC8);
  static const Color paperPlaneAccent = Color(0xFF5B9BD5);
  static const Color starAccent = Color(0xFFE8C547);
  static const Color seedlingAccent = Color(0xFF5DB87A);

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final ink = dark ? textPrimaryDark : textPrimaryLight;
    final muted = dark ? textSecondaryDark : textSecondaryLight;
    final surface = dark ? surfaceDark : surfaceLight;
    final line = dark ? borderDark : borderLight;
    final brand = dark ? primaryDark : primary;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: brand,
      onPrimary: dark ? backgroundDark : Colors.white,
      primaryContainer: dark ? const Color(0xFF293D32) : primaryContainer,
      onPrimaryContainer: ink,
      secondary: dark ? const Color(0xFFB6CDA8) : secondary,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      outline: line,
      outlineVariant: line,
      error: dark ? const Color(0xFFFFB4AB) : error,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final text =
        GoogleFonts.dmSansTextTheme(
          ThemeData(brightness: brightness).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.dmSans(
            fontSize: 44,
            height: 1.12,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.4,
            color: ink,
          ),
          headlineLarge: GoogleFonts.dmSans(
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: -.9,
            color: ink,
          ),
          headlineMedium: GoogleFonts.dmSans(
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
            color: ink,
          ),
          headlineSmall: GoogleFonts.dmSans(
            fontSize: 20,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleLarge: GoogleFonts.dmSans(
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
          titleMedium: GoogleFonts.dmSans(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
          bodyLarge: GoogleFonts.dmSans(fontSize: 16, height: 1.5, color: ink),
          bodyMedium: GoogleFonts.dmSans(fontSize: 14, height: 1.5, color: ink),
          bodySmall: GoogleFonts.dmSans(
            fontSize: 13,
            height: 1.45,
            color: muted,
          ),
        );
    final button = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: WidgetStatePropertyAll(shape),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? backgroundDark : backgroundLight,
      textTheme: text,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarThemeData(
        backgroundColor: dark ? backgroundDark : backgroundLight,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(style: button),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: button.copyWith(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? line : brand,
          ),
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: button),
      textButtonTheme: TextButtonThemeData(style: button),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: brand, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(color: muted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: line),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        labelStyle: TextStyle(fontSize: 13, color: ink),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: line),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        constraints: const BoxConstraints(maxWidth: 640),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
    );
  }
}
