import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../presentation/atoms/circle_surface.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleSurface(
              size: 72,
              child: Icon(
                Icons.forum_outlined,
                color: palette.accentPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.translate.chatEmptyTitle,
              textAlign: TextAlign.center,
              style: typography.screenTitle.copyWith(
                fontSize: 22,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.translate.chatEmptySubtitle,
              textAlign: TextAlign.center,
              style: typography.screenSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
