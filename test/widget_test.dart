import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rumour_room/src/core/extensions/context_extensions.dart';
import 'package:rumour_room/src/core/theme/app_palette.dart';
import 'package:rumour_room/src/core/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme.dark resolves AppPalette + AppTypography via context',
      (tester) async {
    AppPalette? resolved;
    String? identityCaption;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) {
            resolved = context.palette;
            identityCaption = context.typography.identityCaption.color
                ?.toARGB32()
                .toRadixString(16);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved, isNotNull);
    expect(resolved!.accentPrimary.toARGB32(), 0xFFA3E635);
    expect(resolved!.identityGradientStart.toARGB32(), 0xFFFDE047);
    expect(identityCaption, isNotNull);
  });
}
