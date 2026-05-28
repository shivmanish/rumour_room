import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/identity_repository.dart';

class GetOrFetchIdentityUseCase
    extends UseCase<ResolvedIdentity, GetOrFetchIdentityParams> {
  GetOrFetchIdentityUseCase(this._repository);

  final IdentityRepository _repository;

  @override
  Future<Either<Failure, ResolvedIdentity>> call(
    GetOrFetchIdentityParams params,
  ) {
    return _repository.getOrFetch(params.roomCode);
  }
}

class GetOrFetchIdentityParams extends Equatable {
  const GetOrFetchIdentityParams({required this.roomCode});

  final String roomCode;

  @override
  List<Object?> get props => [roomCode];
}
