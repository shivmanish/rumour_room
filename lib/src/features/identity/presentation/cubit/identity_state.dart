import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/identity_entity.dart';

sealed class IdentityState extends Equatable {
  const IdentityState();

  @override
  List<Object?> get props => const [];
}

final class IdentityInitial extends IdentityState {
  const IdentityInitial();
}

final class IdentityLoading extends IdentityState {
  const IdentityLoading();
}

/// [isFresh] = first time this device joined this room → show overlay.
final class IdentityLoaded extends IdentityState {
  const IdentityLoaded({required this.identity, required this.isFresh});

  final IdentityEntity identity;
  final bool isFresh;

  IdentityLoaded copyWith({IdentityEntity? identity, bool? isFresh}) {
    return IdentityLoaded(
      identity: identity ?? this.identity,
      isFresh: isFresh ?? this.isFresh,
    );
  }

  @override
  List<Object?> get props => [identity, isFresh];
}

final class IdentityFailure extends IdentityState {
  const IdentityFailure(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
