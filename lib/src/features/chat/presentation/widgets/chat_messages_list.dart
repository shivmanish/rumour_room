import 'package:flutter/material.dart';

import '../../../../core/cubit/paginated_list/paginated_list_state.dart';
import '../../../../core/cubit/paginated_list/paginated_list_view.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../presentation/atoms/app_loader.dart';
import '../../../../presentation/molecules/centered_app_loader.dart';
import '../../domain/entities/message_entity.dart';
import '../cubit/chat/chat_cubit.dart';
import 'chat_empty_state.dart';
import 'date_separator.dart';
import 'message_row.dart';

/// Buffer is newest-first; rendered `reverse: true` so index 0 is the
/// bottom (latest). Sender labels and date pills are computed per-row.
class ChatMessagesList extends PaginatedListView<MessageEntity, ChatCubit> {
  const ChatMessagesList({super.key, required super.cubit})
    : super(reverse: true, padding: const EdgeInsets.only(top: 12));

  @override
  Widget listItemBuilder(
    MessageEntity message,
    BuildContext context,
    int index,
  ) {
    final items = cubit.state.items;
    // reverse list: items[index+1] is the older message (above this one)
    final older = (index + 1 < items.length) ? items[index + 1] : null;
    final isMine = cubit.isMyMessage(message);
    final separator = _shouldShowDateSeparator(current: message, older: older);
    final startsGroup =
        separator || !_continuesSenderRun(current: message, older: older);
    final row = MessageRow(
      message: message,
      isMine: isMine,
      showSenderLabel: startsGroup,
      startsGroup: startsGroup,
    );

    if (!separator) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DateSeparator(date: message.sentAt ?? DateTime.now()),
        row,
      ],
    );
  }

  bool _shouldShowDateSeparator({
    required MessageEntity current,
    required MessageEntity? older,
  }) {
    if (older == null) return true;
    final currentDate = current.sentAt;
    if (currentDate == null) return false; // pending — skip
    final olderDate = older.sentAt;
    if (olderDate == null) return true;
    return !currentDate.isSameDayAs(olderDate);
  }

  bool _continuesSenderRun({
    required MessageEntity current,
    required MessageEntity? older,
  }) {
    if (older == null) return false;
    if (current.authorId != older.authorId) return false;

    final currentDate = current.sentAt;
    final olderDate = older.sentAt;
    if (currentDate == null || olderDate == null) return true;
    return currentDate.isSameDayAs(olderDate);
  }

  @override
  Widget noItemFoundBuilder(BuildContext context) => const ChatEmptyState();

  @override
  Widget listingErrorWidget(PaginatedListState<MessageEntity> state) {
    return _ListMessage(message: (state as PaginatedListError).failure.message);
  }

  @override
  void onListingError(PaginatedListState<MessageEntity> state) {
    // no-op — error already rendered by listingErrorWidget
  }

  @override
  Widget initialStateWidget(BuildContext context) => const CenteredAppLoader();

  @override
  Widget listingStateWidget(BuildContext context) => const CenteredAppLoader();

  @override
  Widget loadingWidget() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Center(child: AppLoader()),
  );
}

class _ListMessage extends StatelessWidget {
  const _ListMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.typography.body,
        ),
      ),
    );
  }
}
