import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failures.dart';
import '../usecases/usecase.dart';

/// Shared cubit base. Adds [safeEmit] (no-op after close) and an optional
/// [handleUseCase] runner for cubits that wrap a single use case.
abstract class BaseCubit<S, T, P> extends Cubit<S> {
  BaseCubit({required S initialState, this.useCase}) : super(initialState);

  final UseCase<T, P>? useCase;

  @protected
  void safeEmit(S next) {
    if (!isClosed) emit(next);
  }

  Future<void> handleUseCase(
    P params, {
    required FutureOr<void> Function(Failure failure) onFailure,
    required FutureOr<void> Function(T data) onSuccess,
  }) async {
    if (useCase == null) return;

    final result = await useCase!.call(params);
    if (isClosed) return;

    await result.fold<Future<void>>(
      (failure) async => await onFailure(failure),
      (data) async => await onSuccess(data),
    );
  }
}
