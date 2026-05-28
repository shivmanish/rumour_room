import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_theme_manager.dart';
import 'circle_surface.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: 'Switch theme',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: AppThemeManager.instance.toggleLightDark,
        child: CircleSurface(
          size: size,
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: size * 0.48,
            color: context.palette.textPrimary,
          ),
        ),
      ),
    );
  }
}
