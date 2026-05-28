class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Duration sendDebounce = Duration(milliseconds: 250);
  static const Duration banner = Duration(seconds: 3);
}
