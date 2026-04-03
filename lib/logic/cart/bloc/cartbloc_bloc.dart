import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_userapp/data/models/cartmodel/cartmodel.dart';
import 'package:flutter_application_userapp/data/models/productmodel/productmodel.dart';
import 'cartbloc_event.dart';
import 'cartbloc_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _currentUserId;

  CartBloc() : super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  // ── Load cart from Firestore ──────────────────────────
  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    _currentUserId = event.userId;
    if (event.userId.isEmpty) {
      emit(const CartState());
      return;
    }
    try {
      final doc = await _db.collection('carts').doc(event.userId).get();
      if (doc.exists && doc.data() != null) {
        final items = (doc.data()!['items'] as List? ?? [])
            .map(
              (item) => Cartmodel(
                product: Productmodel(
                  id: item['product']['id'] ?? '',
                  name: item['product']['name'] ?? '',
                  description: item['product']['description'] ?? '',
                  price: (item['product']['price'] as num).toDouble(),
                  imageUrl: item['product']['imageUrl'] ?? '',
                  category: item['product']['category'] ?? '',
                  rating: (item['product']['rating'] as num).toDouble(),
                ),
                quantity: item['quantity'],
              ),
            )
            .toList();
        emit(CartState(items: items));
      } else {
        emit(const CartState());
      }
    } catch (_) {
      emit(const CartState());
    }
  }

  // ── Add to cart ───────────────────────────────────────
  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final items = List<Cartmodel>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == event.product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(Cartmodel(product: event.product, quantity: 1));
    }
    final newState = state.copyWith(items: items);
    emit(newState);
    _saveCart(newState);
  }

  // ── Remove from cart ──────────────────────────────────
  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final items = state.items
        .where((i) => i.product.id != event.productId)
        .toList();
    final newState = state.copyWith(items: items);
    emit(newState);
    _saveCart(newState);
  }

  // ── Update quantity ───────────────────────────────────
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
    final newState = state.copyWith(items: items);
    emit(newState);
    _saveCart(newState);
  }

  // ── Clear cart ────────────────────────────────────────
  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    emit(const CartState());
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      await _db.collection('carts').doc(_currentUserId).delete();
    }
  }

  // ── Save cart to Firestore ────────────────────────────
  Future<void> _saveCart(CartState cartState) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    try {
      await _db.collection('carts').doc(_currentUserId).set({
        'userId': _currentUserId,
        'items': cartState.items
            .map(
              (item) => {
                'product': {
                  'id': item.product.id,
                  'name': item.product.name,
                  'description': item.product.description,
                  'price': item.product.price,
                  'imageUrl': item.product.imageUrl,
                  'category': item.product.category,
                  'rating': item.product.rating,
                },
                'quantity': item.quantity,
              },
            )
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
