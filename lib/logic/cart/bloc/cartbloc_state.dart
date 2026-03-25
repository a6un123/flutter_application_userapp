import 'package:equatable/equatable.dart';
import 'package:flutter_application_userapp/data/models/cartmodel/cartmodel.dart';

class CartState extends Equatable {
  final List<Cartmodel> items;

  const CartState({this.items = const []});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  CartState copyWith({List<Cartmodel>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
