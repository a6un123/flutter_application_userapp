import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_userapp/data/models/cartmodel/cartmodel.dart';
import 'package:flutter_application_userapp/data/models/productmodel/productmodel.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final String userEmail;
  final List<Cartmodel> items;
  final double totalPrice;
  final String status;
  final DateTime orderedAt;
  final String address;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.orderedAt,
    required this.address,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
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

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      items: (data['items'] as List)
          .map(
            (item) => Cartmodel(
              product: Productmodel(
                id: item['product']['id'],
                name: item['product']['name'],
                description: item['product']['description'],
                price: (item['product']['price'] as num).toDouble(),
                imageUrl: item['product']['imageUrl'],
                category: item['product']['category'],
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
    );
  }

  OrderModel copyWith({String? status}) {
    return OrderModel(
      orderId: orderId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      items: items,
      totalPrice: totalPrice,
      status: status ?? this.status,
      orderedAt: orderedAt,
      address: address,
    );
  }
}
