import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../cubit/room_code/room_code_form_cubit.dart';
import '../cubit/room_code/room_code_form_state.dart';

/// Stateless — all state (controller, focus, code) lives in [RoomCodeFormCubit].
class RoomCodeInput extends StatelessWidget {
  const RoomCodeInput({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final form = context.read<RoomCodeFormCubit>();
    final palette = context.palette;

    return BlocBuilder<RoomCodeFormCubit, RoomCodeFormState>(
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? form.requestFocus : null,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: palette.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // hidden capture field — holds the text, no visible glyphs
                Positioned.fill(
                  child: TextField(
                    controller: form.codeController,
                    focusNode: form.focusNode,
                    autofocus: true,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(state.length),
                    ],
                    style: const TextStyle(
                      color: Colors.transparent,
                      height: 1,
                    ),
                    cursorColor: Colors.transparent,
                    cursorWidth: 0,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List<Widget>.generate(state.length, (i) {
                    final filled = i < state.code.length;
                    return _Slot(
                      filled: filled,
                      digit: filled ? state.code[i] : null,
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.filled, required this.digit});

  final bool filled;
  final String? digit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Center(
        child: filled
            ? Text(
                digit!,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              )
            : Container(
                width: 14,
                height: 2,
                decoration: BoxDecoration(
                  color: context.palette.textMuted,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
      ),
    );
  }
}
