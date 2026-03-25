import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

// Single event to load and stream products
class FetchProducts extends ProductEvent {}
