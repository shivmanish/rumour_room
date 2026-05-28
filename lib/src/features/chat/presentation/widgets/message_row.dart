import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../presentation/molecules/chat_bubble.dart';
import '../../domain/entities/message_entity.dart';

class MessageRow extends StatelessWidget {
  const MessageRow({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSenderLabel,
    required this.startsGroup,
  });

  final MessageEntity message;
  final bool isMine;
  final bool showSenderLabel;
  final bool startsGroup;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, startsGroup ? 10 : 2, 16, 2),
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (showSenderLabel) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                isMine
                    ? context.translate.chatYouLabel
                    : '@${message.authorUsername}',
                style: typography.username,
              ),
            ),
            const SizedBox(height: 6),
          ],
          ChatMessageBubble(
            isSender: isMine,
            bubbleColor: isMine ? palette.accentPrimary : palette.surfaceCard,
            showTail: startsGroup,
            messageChild: _BubbleContent(
              text: message.text,
              sentAt: message.sentAt,
              isMine: isMine,
              isPending: message.isPending,
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.text,
    required this.sentAt,
    required this.isMine,
    required this.isPending,
  });

  final String text;
  final DateTime? sentAt;
  final bool isMine;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    final textColor = isMine ? palette.onAccent : palette.textPrimary;
    final metaColor = isMine
        ? palette.onAccent.withValues(alpha: 0.6)
        : palette.textMuted;

    // fall back to local clock while serverTimestamp is unresolved —
    // otherwise pending bubbles would show no time until sync
    final timeText = (sentAt ?? DateTime.now()).hhmm;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: typography.message.copyWith(color: textColor)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: typography.messageMeta.copyWith(color: metaColor),
              ),
              if (isMine) ...[
                const SizedBox(width: 4),
                Icon(
                  isPending ? Icons.access_time : Icons.done,
                  size: 12,
                  color: metaColor,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
