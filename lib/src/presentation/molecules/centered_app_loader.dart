import 'package:flutter/material.dart';

import '../atoms/app_loader.dart';

class CenteredAppLoader extends StatelessWidget {
  const CenteredAppLoader({super.key, this.size = 22, this.padding});

  final double size;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Center(child: AppLoader(size: size)),
    );
  }
}
