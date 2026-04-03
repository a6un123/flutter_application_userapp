import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_application_userapp/data/models/ordermodel/ordermodel.dart';

class OrderRepository {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'orders';

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

  // Update status + save date + send notification
  Future<void> updateStatus(String orderId, String status) async {
    // Get order details first
    final orderDoc = await _db.collection(_collection).doc(orderId).get();
    final orderData = orderDoc.data();
    if (orderData == null) return;

    final dateField = switch (status) {
      'confirmed' => 'confirmedAt',
      'shipped' => 'shippedAt',
      'delivered' => 'deliveredAt',
      'cancelled' => 'cancelledAt',
      _ => null,
    };

    final Map<String, dynamic> updateData = {'status': status};
    if (dateField != null) {
      updateData[dateField] = FieldValue.serverTimestamp();
    }

    await _db.collection(_collection).doc(orderId).update(updateData);

    // ── Send notification to user ──────────────
    final userId = orderData['userId'] ?? '';
    final shortId = orderId.substring(0, 8).toUpperCase();

    final messages = {
      'confirmed': (
        'Order Confirmed! ✅',
        'Your order #$shortId has been confirmed',
      ),
      'shipped': ('Order Shipped! 🚚', 'Your order #$shortId is on the way'),
      'delivered': (
        'Order Delivered! 🎉',
        'Your order #$shortId has been delivered',
      ),
      'cancelled': (
        'Order Cancelled ❌',
        'Your order #$shortId has been cancelled',
      ),
    };

    final msg = messages[status];
    if (msg != null && userId.isNotEmpty) {
      await _sendNotificationToUser(
        userId: userId,
        title: msg.$1,
        body: msg.$2,
        orderId: orderId,
        type: 'order_$status',
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final orderDoc = await _db.collection(_collection).doc(orderId).get();
    final userId = orderDoc.data()?['userId'] ?? '';
    final shortId = orderId.substring(0, 8).toUpperCase();

    await _db.collection(_collection).doc(orderId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    if (userId.isNotEmpty) {
      await _sendNotificationToUser(
        userId: userId,
        title: 'Order Cancelled ❌',
        body: 'Your order #$shortId has been cancelled',
        orderId: orderId,
        type: 'order_cancelled',
      );
    }
  }

  // Save notification to Firestore
  Future<void> _sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String orderId,
    required String type,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'orderId': orderId,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
