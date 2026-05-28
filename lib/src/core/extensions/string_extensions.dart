extension StringX on String {
  String get digitsOnly => replaceAll(RegExp(r'[^0-9]'), '');

  String get compact => replaceAll(RegExp(r'\s+'), '');

  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;

  String ellipsize(int max) =>
      length <= max ? this : '${substring(0, max)}…';
}
