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

## Struktur folder

lib/
├── main.dart # entry point: init Hive & notifikasi, cek session
├── models/
│ └── product.dart # model Product & Review
├── services/
│ ├── api_service.dart # HTTP GET produk dari API
│ ├── session_service.dart # simpan/baca/hapus username (SharedPreferences)
│ ├── cart_service.dart # CRUD keranjang di Hive, dipisah per username
│ └── notification_service.dart # notifikasi lokal saat Add to Cart
├── pages/
│ ├── login_page.dart # halaman login
│ ├── main_page.dart # bottom navigation (Home, Profile)
│ ├── home_page.dart # info user, tombol cart, list produk
│ ├── detail_page.dart # detail produk, atur qty, Add to Cart
│ ├── cart_page.dart # keranjang milik user yang login
│ └── profile_page.dart # info user, deskripsi, logout
├── widgets/
│ ├── product_image.dart # gambar jaringan + loading/error state
│ └── qty_stepper.dart # tombol +/- jumlah
├── theme/
│ └── app_theme.dart # warna dan tema aplikasi
└── utils/
└── format.dart # helper format harga, kategori, sapaan

## Alur data

1. `main.dart` membuka box Hive `cart`, lalu mengecek username di SharedPreferences.
   Ada → `MainPage`, tidak ada → `LoginPage`.
2. `HomePage` memanggil `ApiService.fetchProducts()` → `List<Product>`.
3. `DetailPage` memanggil `CartService.add(username, product, qty)`.
   Data disimpan di Hive dengan key `username_productId`.
4. `CartPage` memanggil `CartService.getItems(username)`, sehingga tiap user hanya melihat keranjangnya sendiri.
5. Logout hanya menghapus session; isi keranjang tetap ada di Hive dan muncul lagi saat user itu login.
