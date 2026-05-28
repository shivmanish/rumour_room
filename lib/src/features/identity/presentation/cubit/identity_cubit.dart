import '../../../../core/cubit/base_cubit.dart';
import '../../domain/repository/identity_repository.dart';
import '../../domain/usecases/get_or_fetch_identity_usecase.dart';
import 'identity_state.dart';

class IdentityCubit
    extends
        BaseCubit<IdentityState, ResolvedIdentity, GetOrFetchIdentityParams> {
  IdentityCubit({required GetOrFetchIdentityUseCase getOrFetchUseCase})
    : super(initialState: const IdentityInitial(), useCase: getOrFetchUseCase);

  Future<void> load(String roomCode) async {
    safeEmit(const IdentityLoading());

    final result = await useCase!.call(
      GetOrFetchIdentityParams(roomCode: roomCode),
    );
    if (isClosed) return;

    result.fold(
      (failure) => safeEmit(IdentityFailure(failure)),
      (resolved) => safeEmit(
        IdentityLoaded(identity: resolved.identity, isFresh: resolved.isFresh),
      ),
    );
  }

  void acknowledgeReveal() {
    final current = state;
    if (current is IdentityLoaded && current.isFresh) {
      safeEmit(current.copyWith(isFresh: false));
    }
  }
}
