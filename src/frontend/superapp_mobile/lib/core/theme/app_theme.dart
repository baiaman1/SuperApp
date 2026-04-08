import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const textColor = Color(0xFF111318);
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF111318),
      onPrimary: Colors.white,
      secondary: Color(0xFF667085),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF111318),
      error: Color(0xFFB42318),
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    );

    final textTheme = GoogleFonts.manropeTextTheme(
      base.textTheme,
    ).apply(
      bodyColor: textColor,
      displayColor: textColor,
    ).copyWith(
      displayLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        color: textColor,
      ),
      displayMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: textColor,
      ),
      displaySmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: textColor,
      ),
      titleLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.manrope(height: 1.35, color: textColor),
      bodyMedium: GoogleFonts.manrope(height: 1.35, color: textColor),
      bodySmall: GoogleFonts.manrope(
        height: 1.35,
        color: const Color(0xFF6B7280),
      ),
      labelLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );

    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF111318),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerColor: const Color(0xFFE5E7EB),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFF8FAFC),
        selectedColor: const Color(0xFF111318),
        secondarySelectedColor: const Color(0xFF111318),
        disabledColor: const Color(0xFFF1F5F9),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF111318),
        ),
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      cardColor: Colors.white,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF111318),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 54),
          elevation: 0,
          textStyle: textTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF111318),
          minimumSize: const Size(0, 50),
          side: const BorderSide(color: Color(0xFFD7DBE2)),
          textStyle: textTheme.titleSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF111318),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF111318),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelMedium?.copyWith(
            color: const Color(0xFF111318),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? Colors.white
                : const Color(0xFF667085),
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF111318),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF111318),
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
        dividerColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF6B7280),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF9CA3AF),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: outline,
        border: outline,
        focusedBorder: outline.copyWith(
          borderSide: const BorderSide(color: Color(0xFF111318), width: 1.3),
        ),
        errorBorder: outline.copyWith(
          borderSide: const BorderSide(color: Color(0xFFB42318)),
        ),
        focusedErrorBorder: outline.copyWith(
          borderSide: const BorderSide(color: Color(0xFFB42318), width: 1.3),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF111318),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF111318);
            }

            return const Color(0xFFF9FAFB);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return const Color(0xFF111318);
          }),
          side: const WidgetStatePropertyAll(
            BorderSide(color: Color(0xFFE5E7EB)),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.titleSmall),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
