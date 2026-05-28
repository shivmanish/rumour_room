import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_room/src/features/join_room/presentation/cubit/room_code/room_code_form_cubit.dart';
import 'package:rumour_room/src/features/join_room/presentation/cubit/room_code/room_code_form_state.dart';

void main() {
  group('RoomCodeFormCubit', () {
    test('initial state is empty, length defaults to 6', () {
      final cubit = RoomCodeFormCubit();
      addTearDown(cubit.close);

      expect(cubit.state, equals(const RoomCodeFormState(length: 6)));
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.isComplete, isFalse);
    });

    test('emits state.copyWith(code: …) when the controller value changes',
        () async {
      final cubit = RoomCodeFormCubit();
      addTearDown(cubit.close);

      final emitted = <RoomCodeFormState>[];
      final sub = cubit.stream.listen(emitted.add);
      addTearDown(sub.cancel);

      cubit.codeController.text = '12';
      cubit.codeController.text = '123456';
      // Let microtasks settle.
      await Future<void>.delayed(Duration.zero);

      expect(emitted.length, 2);
      expect(emitted[0].code, '12');
      expect(emitted[0].isPartial, isTrue);
      expect(emitted[1].code, '123456');
      expect(emitted[1].isComplete, isTrue);
    });

    test('does not emit when the new value equals the current code',
        () async {
      final cubit = RoomCodeFormCubit();
      addTearDown(cubit.close);
      cubit.codeController.text = '12';

      final after = <RoomCodeFormState>[];
      final sub = cubit.stream.listen(after.add);
      addTearDown(sub.cancel);

      // Re-set to the same value — listener fires but cubit guards.
      cubit.codeController.notifyListeners();
      await Future<void>.delayed(Duration.zero);

      expect(after, isEmpty);
    });

    test('clear() empties the controller and re-emits an empty state',
        () async {
      final cubit = RoomCodeFormCubit();
      addTearDown(cubit.close);
      cubit.codeController.text = '12345';

      final after = <RoomCodeFormState>[];
      final sub = cubit.stream.listen(after.add);
      addTearDown(sub.cancel);

      cubit.clear();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.codeController.text, '');
      expect(after.last.code, '');
      expect(after.last.isEmpty, isTrue);
    });

    test('clear() is a no-op when already empty', () async {
      final cubit = RoomCodeFormCubit();
      addTearDown(cubit.close);

      final after = <RoomCodeFormState>[];
      final sub = cubit.stream.listen(after.add);
      addTearDown(sub.cancel);

      cubit.clear();
      await Future<void>.delayed(Duration.zero);

      expect(after, isEmpty);
    });

    test('copyWith on state preserves untouched fields', () {
      const initial = RoomCodeFormState(code: 'abc', length: 6);
      final copy = initial.copyWith(code: 'xyz');
      expect(copy.code, 'xyz');
      expect(copy.length, 6);
    });
  });
}
