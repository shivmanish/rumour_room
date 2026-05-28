import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../presentation/atoms/circle_surface.dart';
import '../cubit/chat/chat_cubit.dart';
import '../cubit/composer/composer_cubit.dart';
import '../cubit/composer/composer_state.dart';

/// Sends are fire-and-forget: bubble appears immediately with a pending
/// clock icon, flips to a check when Firestore confirms.
class ChatComposer extends StatelessWidget {
  const ChatComposer({super.key});

  void _onSendTap(BuildContext context) {
    final composer = context.read<ComposerCubit>();
    final chat = context.read<ChatCubit>();
    if (!composer.state.canSend) return;

    final text = composer.state.text;
    composer.reset(); // clear immediately so the input feels instant

    chat.send(text).then((result) {
      if (!context.mounted) return;
      result.fold(
        (failure) => context.showSnack(failure.message, isError: true),
        (_) {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(child: _InputField()),
            const SizedBox(width: 12),
            _SendButton(onTap: () => _onSendTap(context)),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final composer = context.read<ComposerCubit>();
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: palette.inputBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: composer.textController,
        focusNode: composer.focusNode,
        maxLines: 5,
        minLines: 1,
        textInputAction: TextInputAction.newline,
        style: context.typography.inputText,
        cursorColor: palette.accentPrimary,
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: context.translate.chatInputHint,
          hintStyle: context.typography.inputHint,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<ComposerCubit, ComposerState>(
      builder: (context, state) {
        final enabled = state.canSend;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1.0 : 0.5,
            child: CircleSurface(
              size: 44,
              color: palette.accentPrimary,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(AppAssets.iconSend),
              ),
            ),
          ),
        );
      },
    );
  }
}
