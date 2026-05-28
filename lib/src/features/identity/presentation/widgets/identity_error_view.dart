import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../presentation/atoms/circle_surface.dart';

/// Friendly error screen for the identity fetch step. Differentiates the
/// no-internet case from generic failures and exposes a retry button.
class IdentityErrorView extends StatelessWidget {
  const IdentityErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final Failure failure;
  final VoidCallback onRetry;

  bool get _isOffline => failure is NetworkFailure;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    final l10n = context.translate;

    final title = _isOffline
        ? l10n.identityErrorOfflineTitle
        : l10n.identityErrorGenericTitle;
    final subtitle = _isOffline
        ? l10n.identityErrorOfflineSubtitle
        : (failure.message.isNotEmpty ? failure.message : l10n.errGeneric);
    final icon = _isOffline ? Icons.wifi_off_rounded : Icons.error_outline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleSurface(
              size: 72,
              child: Icon(icon, color: palette.accentPrimary, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: typography.screenTitle.copyWith(
                fontSize: 22,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: typography.screenSubtitle,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.actionRetry),
              style: FilledButton.styleFrom(
                backgroundColor: palette.accentPrimary,
                foregroundColor: palette.onAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
