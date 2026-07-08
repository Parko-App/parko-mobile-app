import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // Tipografía personalizada (Nunito e Inter) paa
      // toy usando google fonts
      textTheme: TextTheme(
        // Título — Nunito 900 (32px)
        displayLarge: GoogleFonts.nunito(
          color: AppColors.primary,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
        // Subtítulo — Nunito 800 (18-20px)
        titleLarge: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: AppColors.textSecondary
        ),
        // Cuerpo — Inter 400 (14-15px)
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        // Cuerpo enfatizado — Inter 600 (14-15px)
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        // Label — Nunito 700 (12-13px)
        labelLarge: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: AppColors.primary,
        ),
      ),

      // Estilo de los campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.inter(
          //color: const Color.fromRGBO(11, 61, 145, 1),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),

      // Estilo de los botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.inter(
            //color: const Color.fromRGBO(11, 61, 145, 1),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}
