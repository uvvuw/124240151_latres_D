class Review {
  final int rating;
  final String comment;
  final String reviewerName;

  Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> j) {
    return Review(
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      comment: j['comment'] ?? '',
      reviewerName: j['reviewerName'] ?? 'Anonim',
    );
  }
}

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
  final double discountPercentage;
  final List<String> images;
  final List<String> tags;
  final String sku;
  final String warranty;
  final String shipping;
  final String availability;
  final String returnPolicy;
  final List<Review> reviews;

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
    this.discountPercentage = 0,
    this.images = const [],
    this.tags = const [],
    this.sku = '',
    this.warranty = '',
    this.shipping = '',
    this.availability = '',
    this.returnPolicy = '',
    this.reviews = const [],
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    final thumb = j['thumbnail'] ?? '';
    final imgs =
        (j['images'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    if (imgs.isEmpty && thumb.toString().isNotEmpty) imgs.add(thumb);

    return Product(
      id: j['id'],
      title: j['title'] ?? '',
      description: j['description'] ?? '',
      category: j['category'] ?? '',
      thumbnail: thumb,
      brand: j['brand'] ?? '-',
      price: (j['price'] as num).toDouble(),
      rating: (j['rating'] as num?)?.toDouble() ?? 0,
      stock: (j['stock'] as num?)?.toInt() ?? 0,
      discountPercentage: (j['discountPercentage'] as num?)?.toDouble() ?? 0,
      images: imgs,
      tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      sku: j['sku'] ?? '',
      warranty: j['warrantyInformation'] ?? '',
      shipping: j['shippingInformation'] ?? '',
      availability: j['availabilityStatus'] ?? '',
      returnPolicy: j['returnPolicy'] ?? '',
      reviews:
          (j['reviews'] as List?)
              ?.map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
