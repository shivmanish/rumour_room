// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Rumour';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get joinTitle => 'Join A Room';

  @override
  String get joinSubtitle => 'Enter the code to join the anon chat room';

  @override
  String get joinCreateRoom => 'Create a new room';

  @override
  String get identityCaption => 'For this room, you are';

  @override
  String get identityHelper =>
      'This is your anonymous identifier, visible only to others in this room.';

  @override
  String get identityCta => 'Acknowledge and continue';

  @override
  String get chatInputHint => 'Type a message';

  @override
  String chatRoomTitle(String code) {
    return 'Room #$code';
  }

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get chatDateToday => 'Today';

  @override
  String get chatDateYesterday => 'Yesterday';

  @override
  String get chatYouLabel => 'You';

  @override
  String get chatAnonymous => 'Anonymous chat';

  @override
  String get chatEmptyTitle => 'Start the rumour';

  @override
  String get chatEmptySubtitle => 'Be the first to say hello in this room.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get errNoNetwork => 'You are offline.';

  @override
  String get errInvalidRoomCode => 'Enter a valid 6-digit room code.';

  @override
  String get errRoomNotFound =>
      'No room with that code. Double-check or create a new one.';

  @override
  String get identityErrorOfflineTitle => 'You\'re offline';

  @override
  String get identityErrorOfflineSubtitle =>
      'We couldn\'t fetch your anonymous identity for this room. Check your connection and try again.';

  @override
  String get identityErrorGenericTitle => 'Couldn\'t load your identity';

  @override
  String get actionRetry => 'Retry';
}
