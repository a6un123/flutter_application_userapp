import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_userapp/data/models/ordermodel/ordermodel.dart';

class OrderRepository {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // USER: place a new order
  Future<void> placeOrder(OrderModel order) async {
    final docRef = _db.collection(_collection).doc();
    final orderWithId = OrderModel(
      orderId: docRef.id,
      userId: order.userId,
      userName: order.userName,
      userEmail: order.userEmail,
      items: order.items,
      totalPrice: order.totalPrice,
      status: 'pending',
      orderedAt: DateTime.now(),
      address: order.address,
    );
    await docRef.set(orderWithId.toFirestore());
  }

  // USER: stream my orders in real-time
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('orderedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList(),
        );
  }

  // ADMIN: stream ALL orders in real-time
  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection(_collection)
        .orderBy('orderedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList(),
        );
  }

  // ADMIN: update order status
  Future<void> updateStatus(String orderId, String status) async {
    await _db.collection(_collection).doc(orderId).update({'status': status});
  }

  // ADMIN: cancel order
  Future<void> cancelOrder(String orderId) async {
    await _db.collection(_collection).doc(orderId).update({
      'status': 'cancelled',
    });
  }
}
