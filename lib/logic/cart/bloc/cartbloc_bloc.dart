import 'package:flutter_application_userapp/data/models/cartmodel/cartmodel.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_event.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final items = List<Cartmodel>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == event.product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(Cartmodel(product: event.product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final items = state.items
        .where((i) => i.product.id != event.productId)
        .toList();
    emit(state.copyWith(items: items));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    final items = List<Cartmodel>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == event.productId);
    if (index >= 0) {
      if (event.quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: event.quantity);
      }
    }
    emit(state.copyWith(items: items));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
