import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // =========================================================
  // COLORS
  // =========================================================

  // Light mode
  static const Color paleLemon = Color(0xFFFFF4A8);
  static const Color softYellow = Color(0xFFFFEFAF);

  // Slightly brighter silk blue
  static const Color silkBlue = Color(0xFF9BCBE5);
  static const Color silkBlueStrong = Color(0xFF78B5D5);

  static const Color softBlueGray = Color(0xFFDCE9EF);
  static const Color softGreen = Color(0xFFDDEBE2);

  // Light backgrounds
  static const Color lightBackground = Color(0xFFF8F9F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSoft = Color(0xFFF0F3F2);

  // Light text
  static const Color lightPrimaryText = Color(0xFF171A1C);
  static const Color lightSecondaryText = Color(0xFF68747B);

  // Dark mode
  // Gray-based, NOT pure black
  static const Color darkBackground = Color(0xFF252A2E);
  static const Color darkSurface = Color(0xFF30363B);
  static const Color darkSurfaceSoft = Color(0xFF394147);
  static const Color darkSurfaceElevated = Color(0xFF424B51);

  static const Color darkPrimaryText = Color(0xFFF1F4F5);
  static const Color darkSecondaryText = Color(0xFFB5C0C5);

  static const Color darkBorder = Color(0xFF485157);

  // Status colors
  static const Color lostColor = Color(0xFFE0AA42);
  static const Color foundColor = Color(0xFF6FAFD0);
  static const Color returnedColor = Color(0xFF78A989);

  // =========================================================
  // THEME MODE CONTROLLER
  // =========================================================

  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  static void toggleTheme() {
    themeModeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  static void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  // =========================================================
  // LIGHT THEME
  // =========================================================

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: lightPrimaryText,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: lightPrimaryText,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: lightPrimaryText,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: lightPrimaryText,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightPrimaryText,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: lightPrimaryText,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: lightSecondaryText,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: lightSecondaryText,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: lightPrimaryText,
      ),
    );

    return ThemeData(
      useMaterial3: true,

      fontFamily: GoogleFonts.inter().fontFamily,

      scaffoldBackgroundColor: lightBackground,

      textTheme: textTheme,

      colorScheme: const ColorScheme.light(
        primary: silkBlueStrong,
        secondary: paleLemon,
        surface: lightSurface,
        onPrimary: lightPrimaryText,
        onSecondary: lightPrimaryText,
        onSurface: lightPrimaryText,
      ).copyWith(surfaceContainerHighest: lightSurfaceSoft),

      // -------------------------------------------------------
      // APP BAR
      // -------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightPrimaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: lightPrimaryText,
        ),
      ),

      // -------------------------------------------------------
      // CARDS
      // -------------------------------------------------------
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,

        // No visible border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // -------------------------------------------------------
      // INPUT FIELDS
      // -------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceSoft,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: silkBlueStrong, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),

        labelStyle: GoogleFonts.inter(color: lightSecondaryText),

        hintStyle: GoogleFonts.inter(color: lightSecondaryText),

        prefixIconColor: lightSecondaryText,
      ),

      // -------------------------------------------------------
      // ELEVATED BUTTON
      // -------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: silkBlue,

          foregroundColor: lightPrimaryText,

          disabledBackgroundColor: lightSurfaceSoft,
          disabledForegroundColor: lightSecondaryText,

          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -------------------------------------------------------
      // OUTLINED BUTTON
      // -------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimaryText,

          side: BorderSide.none,

          backgroundColor: lightSurfaceSoft,

          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -------------------------------------------------------
      // TEXT BUTTON
      // -------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimaryText,

          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -------------------------------------------------------
      // ICONS
      // -------------------------------------------------------
      iconTheme: const IconThemeData(color: lightPrimaryText, size: 21),

      // -------------------------------------------------------
      // CHIPS
      // -------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: lightSurfaceSoft,
        selectedColor: paleLemon,

        side: BorderSide.none,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightPrimaryText,
        ),

        secondaryLabelStyle: GoogleFonts.inter(color: lightPrimaryText),

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),

      // -------------------------------------------------------
      // DIALOG
      // -------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        elevation: 0,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),

        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightPrimaryText,
        ),

        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: lightSecondaryText,
        ),
      ),

      // -------------------------------------------------------
      // SNACKBAR
      // -------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor: lightPrimaryText,

        contentTextStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      dividerTheme: const DividerThemeData(
        color: lightSurfaceSoft,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // =========================================================
  // DARK THEME
  // =========================================================

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: darkPrimaryText,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: darkPrimaryText,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: darkPrimaryText,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: darkPrimaryText,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkPrimaryText,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: darkPrimaryText,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkSecondaryText,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: darkSecondaryText,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkPrimaryText,
      ),
    );

    return ThemeData(
      useMaterial3: true,

      fontFamily: GoogleFonts.inter().fontFamily,

      scaffoldBackgroundColor: darkBackground,

      textTheme: textTheme,

      colorScheme: const ColorScheme.dark(
        primary: silkBlue,
        secondary: paleLemon,
        surface: darkSurface,
        onPrimary: Color(0xFF172027),
        onSecondary: Color(0xFF1D2022),
        onSurface: darkPrimaryText,
      ).copyWith(surfaceContainerHighest: darkSurfaceSoft),

      // -------------------------------------------------------
      // APP BAR
      // -------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkPrimaryText,
        elevation: 0,
        centerTitle: false,

        titleTextStyle: GoogleFonts.inter(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: darkPrimaryText,
        ),
      ),

      // -------------------------------------------------------
      // CARDS
      // -------------------------------------------------------
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,

        // No visible border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // -------------------------------------------------------
      // INPUT FIELDS
      // -------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        // Gray field instead of black
        fillColor: darkSurfaceSoft,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: silkBlue, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),

        labelStyle: GoogleFonts.inter(color: darkSecondaryText),

        hintStyle: GoogleFonts.inter(color: darkSecondaryText),

        prefixIconColor: darkSecondaryText,
      ),

      // -------------------------------------------------------
      // ELEVATED BUTTON
      // -------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: silkBlue,

          foregroundColor: const Color(0xFF172027),

          disabledBackgroundColor: darkSurfaceElevated,
          disabledForegroundColor: darkSecondaryText,

          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -------------------------------------------------------
      // OUTLINED BUTTON
      // -------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimaryText,

          side: BorderSide.none,

          backgroundColor: darkSurfaceSoft,

          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -------------------------------------------------------
      // TEXT BUTTON
      // -------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: silkBlue,

          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -------------------------------------------------------
      // ICONS
      // -------------------------------------------------------
      iconTheme: const IconThemeData(color: darkPrimaryText, size: 21),

      // -------------------------------------------------------
      // CHIPS
      // -------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceSoft,
        selectedColor: const Color(0xFF665F32),

        side: BorderSide.none,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkPrimaryText,
        ),

        secondaryLabelStyle: GoogleFonts.inter(color: darkPrimaryText),

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),

      // -------------------------------------------------------
      // DIALOG
      // -------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 0,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),

        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkPrimaryText,
        ),

        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: darkSecondaryText,
        ),
      ),

      // -------------------------------------------------------
      // SNACKBAR
      // -------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor: darkSurfaceElevated,

        contentTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: darkPrimaryText,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      dividerTheme: const DividerThemeData(
        color: darkSurfaceElevated,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
