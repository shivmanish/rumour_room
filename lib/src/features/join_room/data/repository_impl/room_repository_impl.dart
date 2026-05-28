import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result_guard.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repository/room_repository.dart';
import '../../domain/usecases/join_or_create_room_usecase.dart';
import '../datasource/room_datasource.dart';

class RoomRepositoryImpl with ResultGuard implements RoomRepository {
  RoomRepositoryImpl({required this.dataSource});

  final RoomDataSource dataSource;

  @override
  Future<Either<Failure, RoomEntity>> joinOrCreate(
    JoinOrCreateRoomParams params,
  ) {
    return guard<RoomEntity>(() async {
      final existing = await dataSource.fetch(params.code);
      if (existing != null) return existing;
      try {
        return await dataSource.create(params.code);
      } on FirestoreException catch (e) {
        throw FirestoreException(
          'Could not create room ${params.code}: ${e.message}',
          code: e.code,
        );
      }
    });
  }
}
