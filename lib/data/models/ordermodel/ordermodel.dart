import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_userapp/data/models/cartmodel/cartmodel.dart';
import 'package:flutter_application_userapp/data/models/productmodel/productmodel.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final List<Cartmodel> items;
  final double totalPrice;
  final String status;
  final DateTime orderedAt;
  final String address;
  final String userAltPhone;

  // ── Status dates ──────────────────────────────
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone = '',
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.orderedAt,
    required this.address,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.userAltPhone = "",
  });

  // ── From Firestore ─────────────────────────────
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'] ?? '',
      userAltPhone: data["userAltPhone"] ?? "",
      items: (data['items'] as List)
          .map(
            (item) => Cartmodel(
              product: Productmodel(
                id: item['product']['id'] ?? '',
                name: item['product']['name'] ?? '',
                description: item['product']['description'] ?? '',
                price: (item['product']['price'] as num).toDouble(),
                imageUrl: item['product']['imageUrl'] ?? '',
                category: item['product']['category'] ?? '',
                rating: (item['product']['rating'] as num).toDouble(),
              ),
              quantity: item['quantity'],
            ),
          )
          .toList(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: data['status'] ?? 'pending',
      orderedAt: (data['orderedAt'] as Timestamp).toDate(),
      address: data['address'] ?? '',
      confirmedAt: data['confirmedAt'] != null
          ? (data['confirmedAt'] as Timestamp).toDate()
          : null,
      shippedAt: data['shippedAt'] != null
          ? (data['shippedAt'] as Timestamp).toDate()
          : null,
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ── To Firestore ───────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      "userAltPhone": userAltPhone,
      'items': items
          .map(
            (item) => {
              'product': {
                'id': item.product.id,
                'name': item.product.name,
                'description': item.product.description,
                'price': item.product.price,
                'imageUrl': item.product.imageUrl,
                'category': item.product.category,
                'rating': item.product.rating,
              },
              'quantity': item.quantity,
            },
          )
          .toList(),
      'totalPrice': totalPrice,
      'status': status,
      'orderedAt': Timestamp.fromDate(orderedAt),
      'address': address,
    };
  }

  OrderModel copyWith({String? status}) {
    return OrderModel(
      orderId: orderId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      items: items,
      totalPrice: totalPrice,
      status: status ?? this.status,
      orderedAt: orderedAt,
      address: address,
      confirmedAt: confirmedAt,
      shippedAt: shippedAt,
      deliveredAt: deliveredAt,
      cancelledAt: cancelledAt,
      userAltPhone: userAltPhone,
    );
  }
}
