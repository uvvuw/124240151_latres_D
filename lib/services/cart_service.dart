import 'package:hive/hive.dart';

import '../models/product.dart';

class CartService {
  static Box get _box => Hive.box('cart');

  // Key = username_productId, jadi cart tiap user terpisah
  static Future<void> add(String username, Product p, int qty) async {
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
      'qty': newQty,
    });
  }

  static List<Map<String, dynamic>> getItems(String username) {
    return _box.values
        .where((e) => e['username'] == username)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<void> remove(String username, int productId) {
    return _box.delete('${username}_$productId');
  }
}
