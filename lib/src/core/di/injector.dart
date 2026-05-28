import 'package:get_it/get_it.dart';

import '../network/firebase/firebase_firestore_client.dart';
import '../network/firebase/firestore_client.dart';
import '../network/network_config.dart';
import '../network/rest/dio_rest_client.dart';
import '../network/rest/rest_client.dart';
import '../services/connectivity_plus_service.dart';
import '../services/connectivity_service.dart';
import '../services/local_storage_service.dart';
import '../../features/join_room/data/datasource/room_datasource.dart';
import '../../features/join_room/data/repository_impl/room_repository_impl.dart';
import '../../features/join_room/domain/repository/room_repository.dart';
import '../../features/join_room/domain/usecases/join_or_create_room_usecase.dart';
import '../../features/join_room/presentation/cubit/join_room/join_room_cubit.dart';

final sl = GetIt.instance;

/// Composition root. The only file allowed to know about every layer.
Future<void> initInjector({required LocalStorageService storage}) async {
  _registerCore(storage: storage);
  _registerJoinRoom();
}

void _registerCore({required LocalStorageService storage}) {
  sl
    ..registerSingleton<LocalStorageService>(storage)
    ..registerLazySingleton<ConnectivityService>(ConnectivityPlusService.new)
    ..registerLazySingleton<RestClient>(
      () => DioRestClient(baseUrl: NetworkConfig.randomUserBaseUrl),
    )
    ..registerLazySingleton<FirestoreClient>(
      () => FirebaseFirestoreClient(sl<ConnectivityService>()),
    );
}

void _registerJoinRoom() {
  sl
    ..registerLazySingleton<RoomDataSource>(
      () => RoomFirestoreDataSourceImpl(sl<FirestoreClient>()),
    )
    ..registerLazySingleton<RoomRepository>(
      () => RoomRepositoryImpl(dataSource: sl()),
    )
    ..registerLazySingleton<JoinOrCreateRoomUseCase>(
      () => JoinOrCreateRoomUseCase(sl()),
    )
    ..registerFactory<JoinRoomCubit>(
      () => JoinRoomCubit(joinOrCreateUseCase: sl()),
    );
}
