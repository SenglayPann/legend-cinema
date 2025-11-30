class OfferModel {
  final String id;
  final String imageUrl;
  final String description;

  OfferModel({
    required this.id,
    required this.imageUrl,
    required this.description,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map, String id) {
    return OfferModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'imageUrl': imageUrl, 'description': description};
  }
}
