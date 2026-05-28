import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'composer_state.dart';

/// Form state for the chat composer. Owns the controller + focus node.
class ComposerCubit extends Cubit<ComposerState> {
  ComposerCubit()
      : textController = TextEditingController(),
        focusNode = FocusNode(),
        super(const ComposerState()) {
    textController.addListener(_onTextChanged);
  }

  final TextEditingController textController;
  final FocusNode focusNode;

  void _onTextChanged() {
    final newText = textController.text;
    if (newText == state.text) return;
    emit(state.copyWith(text: newText));
  }

  void reset() {
    if (textController.text.isNotEmpty) {
      textController.clear();
      // listener emits the empty state
    }
  }

  @override
  Future<void> close() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    focusNode.dispose();
    return super.close();
  }
}
