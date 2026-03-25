import 'package:cloud_firestore/cloud_firestore.dart';

class Productmodel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;

  const Productmodel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
  });

  // ── From Firestore ─────────────────────────────
  factory Productmodel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Productmodel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] as num).toDouble(),
    );
  }

  // ── From fake API (keep for reference) ─────────
  factory Productmodel.fromJson(Map<String, dynamic> json) {
    return Productmodel(
      id: json['id'].toString(),
      name: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating']['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Productmodel copyWith({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    double? rating,
  }) {
    return Productmodel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
    );
  }
}
