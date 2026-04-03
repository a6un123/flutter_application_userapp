import 'package:equatable/equatable.dart';
import 'package:flutter_application_userapp/data/models/productmodel/productmodel.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

// ← NEW — load cart for specific user
class LoadCart extends CartEvent {
  final String userId;
  const LoadCart(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AddToCart extends CartEvent {
  final Productmodel product;
  const AddToCart(this.product);
  @override
  List<Object?> get props => [product];
}

class RemoveFromCart extends CartEvent {
  final String productId;
  const RemoveFromCart(this.productId);
  @override
  List<Object?> get props => [productId];
}

class UpdateQuantity extends CartEvent {
  final String productId;
  final int quantity;
  const UpdateQuantity({required this.productId, required this.quantity});
  @override
  List<Object?> get props => [productId, quantity];
}

class ClearCart extends CartEvent {}
