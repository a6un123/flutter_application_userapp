import 'package:equatable/equatable.dart';
import 'package:flutter_application_userapp/data/models/productmodel/productmodel.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Productmodel> products;
  const ProductLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}
