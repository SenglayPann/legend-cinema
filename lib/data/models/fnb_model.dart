class FnbModel {
  final String id;
  final String cinemaId;
  final String name;
  final String nameLowercase;
  final String category; // 'snack' | 'beverage' | 'combo'
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final bool isAvailable;
  final int stock;
  final int sortOrder;

  FnbModel({
    required this.id,
    required this.cinemaId,
    required this.name,
    required this.nameLowercase,
    required this.category,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.isAvailable,
    required this.stock,
    required this.sortOrder,
  });

  factory FnbModel.fromMap(Map<String, dynamic> data, String id) {
    return FnbModel(
      id: id,
      cinemaId: data['cinemaId'] ?? '',
      name: data['name'] ?? '',
      nameLowercase: data['nameLowercase'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discountPrice: data['discountPrice'] != null
          ? (data['discountPrice'] as num).toDouble()
          : null,
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      stock: data['stock'] ?? 0,
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cinemaId': cinemaId,
      'name': name,
      'nameLowercase': nameLowercase,
      'category': category,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'stock': stock,
      'sortOrder': sortOrder,
    };
  }
}
