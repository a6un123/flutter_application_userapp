import 'package:equatable/equatable.dart';
import 'package:flutter_application_userapp/data/models/productmodel/productmodel.dart';

class Cartmodel extends Equatable {
  final Productmodel product;
  final int quantity;

  const Cartmodel({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;

  Cartmodel copyWith({int? quantity}) {
    return Cartmodel(product: product, quantity: quantity ?? this.quantity);
  }

  @override
  List<Object?> get props => [product, quantity];
}
