// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'रूमर';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get joinTitle => 'रूम में शामिल हों';

  @override
  String get joinSubtitle => 'एनॉन चैट रूम में शामिल होने के लिए कोड दर्ज करें';

  @override
  String get joinCreateRoom => 'नया रूम बनाएँ';

  @override
  String get identityCaption => 'इस रूम में आप हैं';

  @override
  String get identityHelper =>
      'यह आपकी गुमनाम पहचान है, जो केवल इस रूम के सदस्यों को दिखती है।';

  @override
  String get identityCta => 'स्वीकार करें और जारी रखें';

  @override
  String get chatInputHint => 'संदेश लिखें';

  @override
  String chatRoomTitle(String code) {
    return 'रूम #$code';
  }

  @override
  String chatMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
      one: '1 सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get chatDateToday => 'आज';

  @override
  String get chatDateYesterday => 'कल';

  @override
  String get chatYouLabel => 'आप';

  @override
  String get chatAnonymous => 'गुमनाम चैट';

  @override
  String get chatEmptyTitle => 'अफ़वाह शुरू करें';

  @override
  String get chatEmptySubtitle => 'इस रूम में पहला नमस्ते भेजें।';

  @override
  String get errGeneric => 'कुछ गड़बड़ हो गई। कृपया पुनः प्रयास करें।';

  @override
  String get errNoNetwork => 'आप ऑफ़लाइन हैं।';

  @override
  String get errInvalidRoomCode => '6 अंकों का वैध रूम कोड दर्ज करें।';

  @override
  String get errRoomNotFound =>
      'इस कोड का कोई रूम नहीं मिला। कोड जाँचें या नया रूम बनाएँ।';

  @override
  String get identityErrorOfflineTitle => 'आप ऑफ़लाइन हैं';

  @override
  String get identityErrorOfflineSubtitle =>
      'हम इस रूम के लिए आपकी गुमनाम पहचान नहीं ला सके। कनेक्शन जाँचें और दोबारा कोशिश करें।';

  @override
  String get identityErrorGenericTitle => 'पहचान लोड नहीं हो सकी';

  @override
  String get actionRetry => 'पुनः प्रयास करें';
}
