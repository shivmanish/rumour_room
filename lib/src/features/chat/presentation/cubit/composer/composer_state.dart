import 'package:equatable/equatable.dart';

/// No isSending flag — sends are fire-and-forget; the bubble shows a
/// pending clock until Firestore confirms.
class ComposerState extends Equatable {
  const ComposerState({this.text = ''});

  final String text;

  bool get canSend => text.trim().isNotEmpty;
  bool get isEmpty => text.isEmpty;

  ComposerState copyWith({String? text}) {
    return ComposerState(text: text ?? this.text);
  }

  @override
  List<Object?> get props => [text];
}
