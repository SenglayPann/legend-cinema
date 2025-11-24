class FnbModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  FnbModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory FnbModel.fromMap(Map<String, dynamic> data, String id) {
    return FnbModel(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
