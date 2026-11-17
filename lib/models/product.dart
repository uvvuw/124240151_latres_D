class Product {
  final int id;
  final int stock;
  final String title;
  final String description;
  final String category;
  final String thumbnail;
  final String brand;
  final double price;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnail,
    required this.brand,
    required this.price,
    required this.rating,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    return Product(
      id: j['id'],
      title: j['title'] ?? '',
      description: j['description'] ?? '',
      category: j['category'] ?? '',
      thumbnail: j['thumbnail'] ?? '',
      brand: j['brand'] ?? '-',
      price: (j['price'] as num).toDouble(),
      rating: (j['rating'] as num).toDouble(),
      stock: j['stock'] ?? 0,
    );
  }
}
