String money(num value) => '\$${value.toStringAsFixed(2)}';

String prettyCategory(String raw) {
  if (raw.isEmpty) return raw;
  final s = raw.replaceAll('-', ' ');
  return s[0].toUpperCase() + s.substring(1);
}
