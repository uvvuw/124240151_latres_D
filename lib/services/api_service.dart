import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  static Future<List<Product>> fetchProducts() async {
    final res = await http.get(Uri.parse('https://dummyjson.com/products'));
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat produk (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    return (data['products'] as List).map((e) => Product.fromJson(e)).toList();
  }
}
