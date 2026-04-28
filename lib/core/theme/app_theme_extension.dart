import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color surfaceContainer;
  final Color successText;
  final EdgeInsets defaultPadding;

  const AppThemeExtension({
    required this.surfaceContainer,
    required this.successText,
    required this.defaultPadding,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? surfaceContainer,
    Color? successText,
    EdgeInsets? defaultPadding,
  }) {
    return AppThemeExtension(
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      successText: successText ?? this.successText,
      defaultPadding: defaultPadding ?? this.defaultPadding,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
      covariant ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t) ?? surfaceContainer,
      successText: Color.lerp(successText, other.successText, t) ?? successText,
      defaultPadding: EdgeInsets.lerp(defaultPadding, other.defaultPadding, t) ?? defaultPadding,
    );
  }
}
