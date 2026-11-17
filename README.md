# Toko Online

## Fitur

- Login: username bebas, password wajib NIM (124240151). Username disimpan sebagai session (SharedPreferences).
- Session: setelah login, menutup lalu membuka aplikasi langsung masuk ke halaman utama sampai user logout.
- Bottom navigation: Home dan Profile.
- Home: sapaan + username, tombol keranjang (badge jumlah item), list produk dari API (bisa diganti tampilan list/grid), pencarian, filter kategori, pull to refresh.
- Detail produk: foto (galeri), harga, rating, stok, deskripsi, tag, info tambahan, review. Atur qty (`0 < qty <= stok`) dan tombol Add to Cart.
- Add to Cart: produk, username, dan qty disimpan ke Hive, lalu muncul notifikasi lokal.
- Cart: hanya menampilkan item milik user yang sedang login, ubah qty, hapus item (dengan Urungkan), kosongkan keranjang, total harga.
- Profile: username, deskripsi, statistik keranjang, tombol logout.

## Alur data

1. `main.dart` membuka box Hive `cart`, lalu mengecek username di SharedPreferences.
   Ada → `MainPage`, tidak ada → `LoginPage`.
2. `HomePage` memanggil `ApiService.fetchProducts()` → `List<Product>`.
3. `DetailPage` memanggil `CartService.add(username, product, qty)`.
   Data disimpan di Hive dengan key `username_productId`.
4. `CartPage` memanggil `CartService.getItems(username)`, sehingga tiap user hanya melihat keranjangnya sendiri.
5. Logout hanya menghapus session; isi keranjang tetap ada di Hive dan muncul lagi saat user itu login.
