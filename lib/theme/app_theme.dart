import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Warm paper, clay, and ink. One system for every screen, light and dark.

class AppTheme {
  // Brand
  static const Color primary = Color(0xFFC4471A);
  static const Color primaryDark = Color(0xFFFFB089);
  static const Color primaryContainer = Color(0xFFFFE8DC);
  static const Color secondary = Color(0xFF245C45);
  static const Color secondaryContainer = Color(0xFFE5F2EA);

  // Semantic
  static const Color success = Color(0xFF1F7A4D);
  static const Color warning = Color(0xFFB86A12);
  static const Color error = Color(0xFFB42318);

  // Light surfaces
  static const Color backgroundLight = Color(0xFFF6F1E7);
  static const Color surfaceLight = Color(0xFFFFFCF8);
  static const Color borderLight = Color(0xFFE6DCD0);
  static const Color textPrimaryLight = Color(0xFF1E1A16);
  static const Color textSecondaryLight = Color(0xFF6E675F);

  // Dark surfaces
  static const Color backgroundDark = Color(0xFF14110E);
  static const Color surfaceDark = Color(0xFF241C17);
  static const Color borderDark = Color(0xFF3D322B);
  static const Color textPrimaryDark = Color(0xFFF8F3EC);
  static const Color textSecondaryDark = Color(0xFFC4B8AA);

  // Playful accents used by object art and highlights
  static const Color honey = Color(0xFFF6C56B);
  static const Color blush = Color(0xFFF8D7C4);
  static const Color sand = Color(0xFFF6E6D8);

  static const Color potatoAccent = Color(0xFFD4A853);
  static const Color heartAccent = Color(0xFFE87070);
  static const Color lotusAccent = Color(0xFFB87DC8);
  static const Color paperPlaneAccent = Color(0xFF5B9BD5);
  static const Color starAccent = Color(0xFFE8C547);
  static const Color seedlingAccent = Color(0xFF5DB87A);

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static List<BoxShadow> lift(bool dark) => [
    BoxShadow(
      color: (dark ? Colors.black : const Color(0xFF3A2418)).withAlpha(
        dark ? 90 : 18,
      ),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final ink = dark ? textPrimaryDark : textPrimaryLight;
    final muted = dark ? textSecondaryDark : textSecondaryLight;
    final surface = dark ? surfaceDark : surfaceLight;
    final canvas = dark ? backgroundDark : backgroundLight;
    final line = dark ? borderDark : borderLight;
    final brand = dark ? primaryDark : primary;
    final wash = dark ? const Color(0xFF3A2A22) : primaryContainer;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: brand,
      onPrimary: dark ? const Color(0xFF3B1408) : Colors.white,
      primaryContainer: wash,
      onPrimaryContainer: ink,
      secondary: dark ? const Color(0xFFB7D7C4) : secondary,
      onSecondary: dark ? const Color(0xFF082117) : Colors.white,
      secondaryContainer: dark ? const Color(0xFF1C332A) : secondaryContainer,
      onSecondaryContainer: ink,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      outline: line,
      outlineVariant: line,
      error: dark ? const Color(0xFFFFB4AB) : error,
    );
    final radius = BorderRadius.circular(18);
    final text =
        GoogleFonts.plusJakartaSansTextTheme(
          ThemeData(brightness: brightness).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.fraunces(
            fontSize: 46,
            height: 1.05,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.4,
            color: ink,
          ),
          headlineLarge: GoogleFonts.fraunces(
            fontSize: 32,
            height: 1.12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
            color: ink,
          ),
          headlineMedium: GoogleFonts.fraunces(
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: ink,
          ),
          headlineSmall: GoogleFonts.fraunces(
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          titleSmall: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            height: 1.5,
            color: ink,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.5,
            color: ink,
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 1.45,
            color: muted,
          ),
          labelLarge: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          labelMedium: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        );
    final button = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: text,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarThemeData(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: button.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? line : brand,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? muted
                : scheme.onPrimary,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: button.copyWith(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? line : brand,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? muted
                : scheme.onPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: button.copyWith(
          side: WidgetStatePropertyAll(BorderSide(color: line)),
          foregroundColor: WidgetStatePropertyAll(ink),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: button.copyWith(foregroundColor: WidgetStatePropertyAll(brand)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: WidgetStatePropertyAll(ink),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(color: muted, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: muted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: wash,
        side: BorderSide(color: line),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: line),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        constraints: const BoxConstraints(maxWidth: 640),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? textPrimaryDark : textPrimaryLight,
        contentTextStyle: TextStyle(color: dark ? backgroundDark : surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.transparent,
        indicatorColor: wash,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? brand : muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? brand : muted,
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: dark ? textPrimaryDark : textPrimaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          color: dark ? backgroundDark : Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
