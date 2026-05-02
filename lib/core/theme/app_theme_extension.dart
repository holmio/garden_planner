import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color surfaceContainer;
  final Color successText;
  final Color gardenSurface;
  final Color gardenBorder;
  final Color gardenGrid;
  final Color terraceFill;
  final Color terraceBorder;
  final EdgeInsets defaultPadding;

  const AppThemeExtension({
    required this.surfaceContainer,
    required this.successText,
    required this.gardenSurface,
    required this.gardenBorder,
    required this.gardenGrid,
    required this.terraceFill,
    required this.terraceBorder,
    required this.defaultPadding,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? surfaceContainer,
    Color? successText,
    Color? gardenSurface,
    Color? gardenBorder,
    Color? gardenGrid,
    Color? terraceFill,
    Color? terraceBorder,
    EdgeInsets? defaultPadding,
  }) {
    return AppThemeExtension(
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      successText: successText ?? this.successText,
      gardenSurface: gardenSurface ?? this.gardenSurface,
      gardenBorder: gardenBorder ?? this.gardenBorder,
      gardenGrid: gardenGrid ?? this.gardenGrid,
      terraceFill: terraceFill ?? this.terraceFill,
      terraceBorder: terraceBorder ?? this.terraceBorder,
      defaultPadding: defaultPadding ?? this.defaultPadding,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t) ??
          surfaceContainer,
      successText: Color.lerp(successText, other.successText, t) ?? successText,
      gardenSurface:
          Color.lerp(gardenSurface, other.gardenSurface, t) ?? gardenSurface,
      gardenBorder:
          Color.lerp(gardenBorder, other.gardenBorder, t) ?? gardenBorder,
      gardenGrid: Color.lerp(gardenGrid, other.gardenGrid, t) ?? gardenGrid,
      terraceFill: Color.lerp(terraceFill, other.terraceFill, t) ?? terraceFill,
      terraceBorder:
          Color.lerp(terraceBorder, other.terraceBorder, t) ?? terraceBorder,
      defaultPadding:
          EdgeInsets.lerp(defaultPadding, other.defaultPadding, t) ??
          defaultPadding,
    );
  }
}
