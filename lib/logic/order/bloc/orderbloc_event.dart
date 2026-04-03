import 'package:equatable/equatable.dart';
import 'package:flutter_application_userapp/data/models/cartmodel/cartmodel.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyOrders extends OrderEvent {
  final String userId;
  const LoadMyOrders(this.userId);
  @override
  List<Object?> get props => [userId];
}

class PlaceOrder extends OrderEvent {
  final List<Cartmodel> items;
  final double totalPrice;
  final String address;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userAltPhone;

  const PlaceOrder({
    required this.items,
    required this.totalPrice,
    required this.address,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone = '',
    this.userAltPhone = '',
  });

  @override
  List<Object?> get props => [
    items,
    totalPrice,
    address,
    userId,
    userName,
    userEmail,
    userPhone,
    userAltPhone,
  ];
}

// ← NEW
class CancelMyOrder extends OrderEvent {
  final String orderId;
  const CancelMyOrder(this.orderId);
  @override
  List<Object?> get props => [orderId];
}
