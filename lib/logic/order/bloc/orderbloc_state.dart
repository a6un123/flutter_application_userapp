import 'package:equatable/equatable.dart';
import 'package:flutter_application_userapp/data/models/ordermodel/ordermodel.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderPlacedSuccess extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}
