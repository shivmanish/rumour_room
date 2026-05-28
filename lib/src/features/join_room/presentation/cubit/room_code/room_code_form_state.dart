import 'package:equatable/equatable.dart';

class RoomCodeFormState extends Equatable {
  const RoomCodeFormState({
    this.code = '',
    this.length = 6,
  });

  final String code;
  final int length;

  bool get isComplete => code.length == length;
  bool get isEmpty => code.isEmpty;
  bool get isPartial => !isEmpty && !isComplete;

  RoomCodeFormState copyWith({String? code, int? length}) {
    return RoomCodeFormState(
      code: code ?? this.code,
      length: length ?? this.length,
    );
  }

  @override
  List<Object?> get props => [code, length];
}
