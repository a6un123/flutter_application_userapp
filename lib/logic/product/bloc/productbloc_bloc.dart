import 'package:flutter_application_userapp/data/repositiories/productrepostiores/productrepostiores.dart';
import 'package:flutter_application_userapp/logic/product/bloc/productbloc_event.dart';
import 'package:flutter_application_userapp/logic/product/bloc/productbloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc(this._repository) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }

  // Real-time stream from Firestore
  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    await emit.forEach(
      _repository.getProducts(),
      onData: (products) => ProductLoaded(products),
      onError: (e, _) => ProductError(e.toString()),
    );
  }
}
