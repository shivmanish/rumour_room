import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';

/// Bare round surface — building block for icon buttons, avatars, etc.
class CircleSurface extends StatelessWidget {
  const CircleSurface({
    super.key,
    this.size = 40,
    this.color,
    this.child,
  });

  final double size;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? context.palette.surfaceElevated,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
