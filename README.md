# toko_online

# Fitur

- Login: username bebas, password = 124240151 Username disimpan sebagai session (SharedPreferences).
- Session tersimpan: setelah login, membuka ulang aplikasi langsung ke halaman utama sampai user logout.
- Bottom navigation: Home dan Profile.
- Home: sapaan username, tombol keranjang (dengan badge jumlah item), daftar produk dari API, pencarian, filter kategori, tarik untuk menyegarkan.
- Detail produk: semua informasi produk, atur qty (0 < qty <= stok), tombol Add to Cart.
- Add to Cart: produk, username, dan qty disimpan ke Hive, lalu muncul notifikasi lokal.
- Cart: hanya menampilkan item milik user yang sedang login, ubah qty (+/-), tombol Hapus di tiap item, kosongkan keranjang, total harga, dan Urungkan.
- Profile: username, deskripsi, tombol logout (dengan konfirmasi).
