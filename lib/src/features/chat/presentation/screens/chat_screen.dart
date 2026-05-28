import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../presentation/atoms/circle_icon_button.dart';
import '../../../../presentation/atoms/theme_toggle_button.dart';
import '../../../../presentation/molecules/centered_app_loader.dart';
import '../../../identity/domain/entities/identity_entity.dart';
import '../../../identity/presentation/cubit/identity_cubit.dart';
import '../../../identity/presentation/cubit/identity_state.dart';
import '../../../identity/presentation/widgets/identity_error_view.dart';
import '../../../identity/presentation/widgets/identity_reveal_overlay.dart';
import '../cubit/chat/chat_cubit.dart';
import '../cubit/composer/composer_cubit.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_messages_list.dart';

/// Identity loads first, then ChatCubit is built inline (needs identity).
/// The BlocProvider wraps the Scaffold so the app bar can read memberCount.
@RoutePage(name: 'ChatRoute')
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, @PathParam('roomCode') required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<IdentityCubit>(
          create: (_) => sl<IdentityCubit>()..load(roomCode),
        ),
        BlocProvider<ComposerCubit>(create: (_) => ComposerCubit()),
      ],
      child: _ChatScaffold(roomCode: roomCode),
    );
  }
}

class _ChatScaffold extends StatelessWidget {
  const _ChatScaffold({required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IdentityCubit, IdentityState>(
      builder: (context, state) {
        return switch (state) {
          IdentityInitial() || IdentityLoading() => Scaffold(
            appBar: _ChatAppBar(roomCode: roomCode),
            body: const CenteredAppLoader(),
          ),
          IdentityFailure(:final failure) => Scaffold(
            appBar: _ChatAppBar(roomCode: roomCode),
            body: IdentityErrorView(
              failure: failure,
              onRetry: () => context.read<IdentityCubit>().load(roomCode),
            ),
          ),
          IdentityLoaded(:final identity, :final isFresh) => _LoadedScaffold(
            roomCode: roomCode,
            identity: identity,
            isFresh: isFresh,
          ),
        };
      },
    );
  }
}

class _LoadedScaffold extends StatelessWidget {
  const _LoadedScaffold({
    required this.roomCode,
    required this.identity,
    required this.isFresh,
  });

  final String roomCode;
  final IdentityEntity identity;
  final bool isFresh;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => ChatCubit(
        repository: sl(),
        loadMessagesUseCase: sl(),
        sendMessageUseCase: sl(),
        roomCode: roomCode,
        authorId: identity.id,
        authorUsername: identity.username,
      ),
      child: Scaffold(
        appBar: _ChatAppBar(roomCode: roomCode, showMemberCount: true),
        body: Stack(
          children: [
            const _ChatBody(),
            if (isFresh)
              Positioned.fill(
                child: IdentityRevealOverlay(
                  identity: identity,
                  onAcknowledge: () =>
                      context.read<IdentityCubit>().acknowledgeReveal(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: ChatMessagesList(cubit: context.read<ChatCubit>())),
        SizedBox(height: 16),
        const ChatComposer(),
      ],
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.roomCode, this.showMemberCount = false});

  final String roomCode;

  /// true only when ChatCubit is in scope.
  final bool showMemberCount;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.translate.chatRoomTitle(roomCode),
                    style: typography.appBarTitle,
                  ),
                  const SizedBox(height: 2),
                  if (showMemberCount)
                    const _MemberSubtitle()
                  else
                    Text(
                      context.translate.chatAnonymous,
                      style: typography.appBarSubtitle,
                    ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: CircleIconButton(
                  asset: AppAssets.iconBack,
                  onTap: () => context.popOrIgnore(),
                ),
              ),
            ),
            const Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(child: ThemeToggleButton()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberSubtitle extends StatelessWidget {
  const _MemberSubtitle();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    return ValueListenableBuilder<int>(
      valueListenable: cubit.memberCount,
      builder: (context, count, _) {
        if (count == 0) {
          return Text(
            context.translate.chatAnonymous,
            style: context.typography.appBarSubtitle,
          );
        }
        return Text(
          context.translate.chatMembersCount(count),
          style: context.typography.appBarSubtitle,
        );
      },
    );
  }
}
