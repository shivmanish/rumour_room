import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/room_code_generator.dart';
import 'room_code_form_state.dart';

/// Form state for the room-code input. Owns the controller + focus node
/// so the widget can stay stateless. Knows nothing about networking.
class RoomCodeFormCubit extends Cubit<RoomCodeFormState> {
  RoomCodeFormCubit({int? length})
    : codeController = TextEditingController(),
      focusNode = FocusNode(),
      super(RoomCodeFormState(length: length ?? RoomCodeGenerator.length)) {
    codeController.addListener(_handleControllerChange);
  }

  final TextEditingController codeController;
  final FocusNode focusNode;

  void _handleControllerChange() {
    final newCode = codeController.text;
    if (newCode == state.code) return;
    emit(state.copyWith(code: newCode));
  }

  void requestFocus() => focusNode.requestFocus();

  void clear() {
    if (codeController.text.isNotEmpty) {
      codeController.clear();
      // listener will emit the empty state
    }
  }

  @override
  Future<void> close() {
    codeController.removeListener(_handleControllerChange);
    codeController.dispose();
    focusNode.dispose();
    return super.close();
  }
}
