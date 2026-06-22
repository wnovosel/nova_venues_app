import 'package:flutter/material.dart';
import '../config/tenant_config.dart';

/// Builds a full ThemeData from a TenantConfig.
/// Every venue gets its own colors/fonts — zero hardcoding.
class AppTheme {
  final TenantConfig config;

  AppTheme(this.config);

  Color get primary     => Color(config.primaryColor);
  Color get background  => Color(config.backgroundColor);
  Color get surface     => Color(config.surfaceColor);
  Color get textPrimary => Color(config.textColor);
  Color get muted       => Color(config.mutedColor);
  Color get border      => Color(config.borderColor);
  Color get navBar      => Color(config.navBarColor);

  ThemeData build() {
    final primaryColor = Color(config.primaryColor);
    final bgColor      = Color(config.backgroundColor);
    final surfaceColor = Color(config.surfaceColor);
    final textColor    = Color(config.textColor);
    final mutedColor   = Color(config.mutedColor);
    final borderColor  = Color(config.borderColor);
    final navBarColor  = Color(config.navBarColor);

    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.light(
        primary:    primaryColor,
        secondary:  primaryColor,
        surface:    surfaceColor,
        background: bgColor,
        onPrimary:  Colors.white,
        onSurface:  textColor,
        onBackground: textColor,
      ),
      scaffoldBackgroundColor: bgColor,

      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontFamily: config.headingFont,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: TextStyle(
            fontFamily: config.bodyFont,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryColor),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        labelStyle: TextStyle(color: mutedColor, fontSize: 13),
        hintStyle:  TextStyle(color: mutedColor, fontSize: 14),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBarColor,
        selectedItemColor:   primaryColor,
        unselectedItemColor: mutedColor,
        selectedLabelStyle:   TextStyle(
            fontFamily: config.bodyFont, fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(
            fontFamily: config.bodyFont, fontWeight: FontWeight.w600, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),

      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
      ),

      dividerTheme: DividerThemeData(color: borderColor, thickness: 1),

      textTheme: TextTheme(
        displayLarge:  TextStyle(color: textColor, fontFamily: config.headingFont,
            fontWeight: FontWeight.w700, fontSize: 36, letterSpacing: 0.5),
        displayMedium: TextStyle(color: textColor, fontFamily: config.headingFont,
            fontWeight: FontWeight.w700, fontSize: 26, letterSpacing: 0.3),
        titleLarge:    TextStyle(color: textColor, fontFamily: config.headingFont,
            fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium:   TextStyle(color: textColor, fontFamily: config.bodyFont,
            fontWeight: FontWeight.w700, fontSize: 16),
        titleSmall:    TextStyle(color: textColor, fontFamily: config.bodyFont,
            fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge:     TextStyle(color: textColor, fontFamily: config.bodyFont,
            fontSize: 15),
        bodyMedium:    TextStyle(color: mutedColor, fontFamily: config.bodyFont,
            fontSize: 13),
        bodySmall:     TextStyle(color: mutedColor, fontFamily: config.bodyFont,
            fontSize: 12),
        labelSmall:    TextStyle(color: mutedColor, fontFamily: config.bodyFont,
            fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  /// Card decoration consistent with this tenant's theme
  BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  /// Hero gradient using primary color
  BoxDecoration heroDecoration({double radius = 22}) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(config.primaryColor),
        Color(config.primaryColor).withOpacity(0.75),
      ],
    ),
    boxShadow: const [
      BoxShadow(color: Color(0x30000000), blurRadius: 20, offset: Offset(0, 8)),
    ],
  );
}
