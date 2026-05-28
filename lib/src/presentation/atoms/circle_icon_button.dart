import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/extensions/context_extensions.dart';
import 'circle_surface.dart';

/// Tappable round button with an SVG glyph inside.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.asset,
    required this.onTap,
    this.size = 40,
    this.iconPadding = 12,
    this.color,
    this.iconColor,
  });

  final String asset;
  final VoidCallback onTap;
  final double size;
  final double iconPadding;
  final Color? color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final tint = iconColor ?? context.palette.textPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: CircleSurface(
        size: size,
        color: color,
        child: Padding(
          padding: EdgeInsets.all(iconPadding),
          child: SvgPicture.asset(
            asset,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
