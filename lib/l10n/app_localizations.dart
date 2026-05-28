import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Rumour'**
  String get appName;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hindi language name
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// Title on the room-code entry screen
  ///
  /// In en, this message translates to:
  /// **'Join A Room'**
  String get joinTitle;

  /// Subtitle on the room-code entry screen
  ///
  /// In en, this message translates to:
  /// **'Enter the code to join the anon chat room'**
  String get joinSubtitle;

  /// Secondary CTA that lets the user create a fresh room
  ///
  /// In en, this message translates to:
  /// **'Create a new room'**
  String get joinCreateRoom;

  /// Small caption above the gradient identity name
  ///
  /// In en, this message translates to:
  /// **'For this room, you are'**
  String get identityCaption;

  /// Helper line beneath the identity name
  ///
  /// In en, this message translates to:
  /// **'This is your anonymous identifier, visible only to others in this room.'**
  String get identityHelper;

  /// Primary CTA that closes the identity reveal sheet
  ///
  /// In en, this message translates to:
  /// **'Acknowledge and continue'**
  String get identityCta;

  /// Placeholder inside the chat input field
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get chatInputHint;

  /// App bar title shown on the chat screen
  ///
  /// In en, this message translates to:
  /// **'Room #{code}'**
  String chatRoomTitle(String code);

  /// Member count line under the room title
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String chatMembersCount(int count);

  /// Date separator label for messages sent today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatDateToday;

  /// Date separator label for messages sent yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatDateYesterday;

  /// Label shown above the current user's own bubble
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatYouLabel;

  /// Subtitle shown in the chat app bar when no members have joined yet
  ///
  /// In en, this message translates to:
  /// **'Anonymous chat'**
  String get chatAnonymous;

  /// Empty-state title shown when a chat room has no messages yet
  ///
  /// In en, this message translates to:
  /// **'Start the rumour'**
  String get chatEmptyTitle;

  /// Empty-state subtitle on the chat screen
  ///
  /// In en, this message translates to:
  /// **'Be the first to say hello in this room.'**
  String get chatEmptySubtitle;

  /// Fallback error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// Banner shown when the device has no connectivity
  ///
  /// In en, this message translates to:
  /// **'You are offline.'**
  String get errNoNetwork;

  /// Inline error for the join screen when the entered code is malformed
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit room code.'**
  String get errInvalidRoomCode;

  /// Inline error for the join screen when the room doesn't exist
  ///
  /// In en, this message translates to:
  /// **'No room with that code. Double-check or create a new one.'**
  String get errRoomNotFound;

  /// Title of the no-internet card shown when the identity API call fails
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get identityErrorOfflineTitle;

  /// Subtitle of the no-internet card on the identity error screen
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t fetch your anonymous identity for this room. Check your connection and try again.'**
  String get identityErrorOfflineSubtitle;

  /// Title shown when identity loading fails for a non-network reason
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your identity'**
  String get identityErrorGenericTitle;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
