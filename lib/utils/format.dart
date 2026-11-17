String money(num value) => '\$${value.toStringAsFixed(2)}';

String prettyCategory(String raw) {
  if (raw.isEmpty) return raw;
  final s = raw.replaceAll('-', ' ');
  return s[0].toUpperCase() + s.substring(1);
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 11) return 'Selamat pagi';
  if (h < 15) return 'Selamat siang';
  if (h < 18) return 'Selamat sore';
  return 'Selamat malam';
}
