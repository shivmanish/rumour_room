import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

/// Lime circular progress indicator. Pre-sized so it drops in anywhere.
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = 18,
    this.strokeWidth = 2,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? context.palette.accentPrimary,
        ),
      ),
    );
  }
}
