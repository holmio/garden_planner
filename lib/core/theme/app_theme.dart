import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_theme_extension.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: AppTypography.fontSizeHeadline,
          fontWeight: AppTypography.fontWeightBold,
          color: AppColors.primary,
        ),
        titleLarge: TextStyle(
          fontSize: AppTypography.fontSizeTitle,
          fontWeight: AppTypography.fontWeightBold,
          color: AppColors.primary,
        ),
        titleMedium: TextStyle(
          fontSize: AppTypography.fontSizeHeading,
          fontWeight: AppTypography.fontWeightMedium,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTypography.fontSizeBody,
          color: AppColors.textPrimary,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      inputDecorationTheme:
          OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)).let(
            (border) => InputDecorationTheme(
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: TextStyle(color: Colors.white),
      ),

      extensions: [
        AppThemeExtension(
          surfaceContainer: Colors.white,
          successText: AppColors.success,
          gardenSurface: AppColors.soilLight,
          gardenBorder: AppColors.soilDark,
          gardenGrid: AppColors.soil,
          terraceFill: AppColors.primaryLight,
          terraceBorder: AppColors.primaryDark,
          defaultPadding: AppSpacing.edgeInsetsAllMd,
        ),
      ],
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T value) transform) => transform(this);
}
