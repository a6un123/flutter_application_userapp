import 'package:flutter_application_userapp/data/repositiories/orderrepositiories/orderrepositiores.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_userapp/data/models/ordermodel/ordermodel.dart';
import 'orderbloc_event.dart';
import 'orderbloc_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;

  OrderBloc(this._repository) : super(OrderInitial()) {
    on<LoadMyOrders>(_onLoadMyOrders);
    on<PlaceOrder>(_onPlaceOrder);
    on<CancelMyOrder>(_onCancelOrder); // ← NEW
  }

  Future<void> _onLoadMyOrders(
      LoadMyOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    await emit.forEach(
      _repository.getUserOrders(event.userId),
      onData: (orders) => OrdersLoaded(orders),
      onError: (e, _) => OrderError(e.toString()),
    );
  }

  Future<void> _onPlaceOrder(
      PlaceOrder event, Emitter<OrderState> emit) async {
    try {
      final order = OrderModel(
        orderId:      '',
        userId:       event.userId,
        userName:     event.userName,
        userEmail:    event.userEmail,
        userPhone:    event.userPhone,
        userAltPhone: event.userAltPhone,
        items:        event.items,
        totalPrice:   event.totalPrice,
        status:       'pending',
        orderedAt:    DateTime.now(),
        address:      event.address,
      );
      await _repository.placeOrder(order);
      emit(OrderPlacedSuccess());
      add(LoadMyOrders(event.userId));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // ← NEW
  Future<void> _onCancelOrder(
      CancelMyOrder event, Emitter<OrderState> emit) async {
    try {
      await _repository.cancelOrder(event.orderId);
      emit(OrderCancelledSuccess());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}