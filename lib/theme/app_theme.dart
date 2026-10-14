import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'brand_colors.dart';

/// Nombres históricos usados por las vistas internas. Todos se apoyan en la
/// paleta de EduRA para mantener una sola línea visual sin alterar sus flujos.
class AppColors {
  static const Color primaryGreen = BrandColors.forest;
  static const Color leafGreen = BrandColors.forest;
  static const Color lightGreen = BrandColors.ivory;
  static const Color mintGreen = BrandColors.amber;
  static const Color skyBlue = BrandColors.forest;
  static const Color lightBlue = BrandColors.ivory;
  static const Color oceanBlue = BrandColors.forest;
  static const Color earthBrown = BrandColors.forestMuted;
  static const Color sandBeige = BrandColors.ivory;
  static const Color sunOrange = BrandColors.amberDark;
  static const Color sunYellow = BrandColors.amber;
  static const Color cloudWhite = BrandColors.ivory;
  static const Color darkText = BrandColors.ink;
  static const Color greyText = BrandColors.forestMuted;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [BrandColors.forest, BrandColors.forest],
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [BrandColors.ivory, BrandColors.ivory],
  );
}

/// Estilos de texto
class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get heading2 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static TextStyle get heading3 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.greyText,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.greyText,
  );

  static TextStyle get button =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.greyText,
  );
}

/// Decoraciones reutilizables
class AppDecorations {
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: BrandColors.forest.withOpacity(0.10)),
    boxShadow: [
      BoxShadow(
        color: BrandColors.forest.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration get gradientCardDecoration => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: BrandColors.forest.withOpacity(0.12),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// Tema de la aplicación
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      primary: AppColors.primaryGreen,
      secondary: BrandColors.amber,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.cloudWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: AppTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: BrandColors.forest.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: BrandColors.forest.withOpacity(0.10)),
      ),
      color: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: BrandColors.forest,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}
