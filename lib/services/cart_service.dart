import 'package:hive/hive.dart';

import '../models/product.dart';

class CartService {
  static Box get _box => Hive.box('cart');

  // Key = username_productId, jadi cart tiap user terpisah
  // Mengembalikan qty akhir produk ini di cart (sudah dibatasi stok)
  static Future<int> add(String username, Product p, int qty) async {
    final key = '${username}_${p.id}';
    final old = _box.get(key);
    final oldQty = old == null ? 0 : (old['qty'] as int);
    int newQty = oldQty + qty;
    if (newQty > p.stock) newQty = p.stock;

    await _box.put(key, {
      'username': username,
      'productId': p.id,
      'title': p.title,
      'price': p.price,
      'thumbnail': p.thumbnail,
      'stock': p.stock,
      'qty': newQty,
    });
    return newQty;
  }

  static int qtyOf(String username, int productId) {
    final old = _box.get('${username}_$productId');
    return old == null ? 0 : (old['qty'] as int);
  }

  static List<Map<String, dynamic>> getItems(String username) {
    return _box.values
        .where((e) => e['username'] == username)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static int count(String username) => getItems(username).length;

  // Ubah jumlah langsung dari halaman cart
  static Future<void> setQty(String username, int productId, int qty) async {
    final key = '${username}_$productId';
    final old = _box.get(key);
    if (old == null) return;
    final item = Map<String, dynamic>.from(old);
    item['qty'] = qty;
    await _box.put(key, item);
  }

  static Future<void> remove(String username, int productId) {
    return _box.delete('${username}_$productId');
  }

  // Hapus semua item milik satu user saja
  static Future<void> clear(String username) {
    final keys = _box.keys.where((k) {
      final v = _box.get(k);
      return v != null && v['username'] == username;
    }).toList();
    return _box.deleteAll(keys);
  }

  // Dipakai untuk tombol "Urungkan"
  static Future<void> restore(String username, Map<String, dynamic> item) {
    return _box.put('${username}_${item['productId']}', item);
  }
}
