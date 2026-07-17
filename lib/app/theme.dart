import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// โทนสี + typography ของแอป — อิงจาก flutter-med-flow-user-app
class AppTheme {
  // ── TYPOGRAPHY ────────────────────────────────────────────────────────────
  static TextStyle generalText(
    double fonSize, {
    Color color = const Color(0xFF25253A),
    FontWeight fonWeight = FontWeight.w400,
    TextDecorationStyle? decorationStyle,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.athiti(
      color: color,
      fontSize: fonSize,
      decorationStyle: decorationStyle,
      decoration: decoration,
      fontWeight: fonWeight,
      fontStyle: FontStyle.normal,
    );
  }

  // ── PRIMARY / BRAND ───────────────────────────────────────────────────────
  static Color get primaryThemeApp => const Color(0xff4A90A9);
  static Color get primary1 => const Color(0xff437689);
  static Color get primary2 => const Color(0xff4A90A9);
  static Color get blueLogo => const Color(0xff2F4A85);

  // ── TEXT ──────────────────────────────────────────────────────────────────
  static Color get primaryText => const Color(0xFF1E293B);
  static Color get secondaryText62 => const Color(0xff64748B);
  static Color get secondaryText9A => const Color(0xff94A3B8);

  // ── BASE ──────────────────────────────────────────────────────────────────
  static Color get whiteColor => const Color(0xffffffff);
  static Color get bgColor => const Color(0xfff8fafc);

  // ── LINE / BORDER ─────────────────────────────────────────────────────────
  static Color get lineColorD9 => const Color(0xffE2E8F0);

  // ── STATUS ────────────────────────────────────────────────────────────────
  static Color get successColor => Colors.green;
  static Color get errorColor => Colors.red;

  // ── SOCIAL BRAND ──────────────────────────────────────────────────────────
  static Color get lineBrand => const Color(0xff06C755);
  static Color get facebookBrand => const Color(0xff1877F2);

  /// ThemeData รวมสำหรับ MaterialApp
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryThemeApp,
      primary: primaryThemeApp,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.athitiTextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: whiteColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lineColorD9),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lineColorD9),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryThemeApp, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryThemeApp,
          foregroundColor: whiteColor,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.athiti(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
