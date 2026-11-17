import 'package:flutter/material.dart';

class AppTheme {
  // ===== PALET WARNA =====
  static const Color seed = Color(0xFF4F46E5); // indigo (warna utama)
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF7C74F5);

  static const Color background = Color(0xFFF5F6FB);
  static const Color border = Color(0xFFE4E6F1);
  static const Color soft = Color(0xFFEEF0FA);

  static const Color ink = Color(0xFF1F2340); // teks utama
  static const Color muted = Color(0xFF6B7194); // teks sekunder
  static const Color mutedLight = Color(0xFFB4B8D0); // ikon/empty state

  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFEA7A0C); // stok menipis, rating
  static const Color star = Color(0xFFFFB400); // bintang rating

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryDark, seed, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dekorasi kartu putih standar yang dipakai di banyak halaman.
  static BoxDecoration card({double radius = 16}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
  );

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: seed)
        .copyWith(primary: seed, onPrimary: Colors.white);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: seed,
        unselectedItemColor: mutedLight,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: seed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: const Color(0xFFA5B4FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
