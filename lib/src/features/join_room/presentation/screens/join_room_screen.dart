import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../presentation/atoms/app_loader.dart';
import '../../../../presentation/atoms/circle_surface.dart';
import '../../../../presentation/atoms/theme_toggle_button.dart';
import '../cubit/join_room/join_room_cubit.dart';
import '../cubit/join_room/join_room_state.dart';
import '../cubit/room_code/room_code_form_cubit.dart';
import '../cubit/room_code/room_code_form_state.dart';
import '../widgets/room_code_input.dart';

@RoutePage(name: 'JoinRoute')
class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JoinRoomCubit>(create: (_) => sl<JoinRoomCubit>()),
        BlocProvider<RoomCodeFormCubit>(create: (_) => RoomCodeFormCubit()),
      ],
      child: const _JoinRoomView(),
    );
  }
}

class _JoinRoomView extends StatelessWidget {
  const _JoinRoomView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            MultiBlocListener(
              listeners: [
                BlocListener<RoomCodeFormCubit, RoomCodeFormState>(
                  listenWhen: (prev, curr) =>
                      !prev.isComplete && curr.isComplete,
                  listener: (context, state) {
                    context.read<JoinRoomCubit>().submit(state.code);
                  },
                ),
                BlocListener<JoinRoomCubit, JoinRoomState>(
                  listenWhen: (prev, curr) =>
                      curr is JoinRoomSuccess || curr is JoinRoomFailure,
                  listener: (context, state) {
                    switch (state) {
                      case JoinRoomSuccess(:final room):
                        context.router.push(ChatRoute(roomCode: room.code));
                      case JoinRoomFailure(:final failure):
                        context.showSnack(failure.message, isError: true);
                      case JoinRoomInitial() || JoinRoomChecking():
                        break;
                    }
                    context.read<RoomCodeFormCubit>().clear();
                    context.read<JoinRoomCubit>().reset();
                  },
                ),
              ],
              child: BlocBuilder<JoinRoomCubit, JoinRoomState>(
                builder: (context, state) {
                  final isChecking = state is JoinRoomChecking;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: CircleSurface(
                            size: 80,
                            child: Padding(
                              padding: const EdgeInsets.all(22),
                              child: SvgPicture.asset(
                                AppAssets.iconRoomKey,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 3),
                        Text(
                          context.translate.joinTitle,
                          textAlign: TextAlign.center,
                          style: context.typography.screenTitle,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            context.translate.joinSubtitle,
                            textAlign: TextAlign.center,
                            style: context.typography.screenSubtitle,
                          ),
                        ),
                        const SizedBox(height: 36),
                        RoomCodeInput(enabled: !isChecking),
                        const SizedBox(height: 16),
                        _CheckingSpinner(visible: isChecking),
                        const Spacer(flex: 5),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Positioned(top: 16, right: 16, child: ThemeToggleButton()),
          ],
        ),
      ),
    );
  }
}

class _CheckingSpinner extends StatelessWidget {
  const _CheckingSpinner({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      child: const SizedBox(height: 20, child: Center(child: AppLoader())),
    );
  }
}
