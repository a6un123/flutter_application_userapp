import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_userapp/data/repositiories/authrepostiories/authrepositery.dart';
import 'package:flutter_application_userapp/data/repositiories/orderrepositiories/orderrepositiores.dart';
import 'package:flutter_application_userapp/data/repositiories/productrepostiores/productrepostiores.dart';
import 'package:flutter_application_userapp/firebase_options.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_event.dart';
import 'package:flutter_application_userapp/logic/cart/bloc/cartbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/order/bloc/orderbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/product/bloc/productbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/product/bloc/productbloc_event.dart';
import 'package:flutter_application_userapp/router/approuter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authRepository = AuthRepository();
  final _orderRepository = OrderRepository();
  final _productRepository = ProductRepository();

  late final AuthBloc _authBloc;
  late final ProductBloc _productBloc;
  late final OrderBloc _orderBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(_authRepository)..add(CheckAuthStatus());
    _productBloc = ProductBloc(_productRepository)..add(FetchProducts());
    _orderBloc = OrderBloc(_orderRepository);
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _productBloc.close();
    _orderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _orderRepository),
        RepositoryProvider.value(value: _productRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _productBloc),
          BlocProvider.value(value: _orderBloc),
          BlocProvider(create: (_) => CartBloc()),
        ],
        child: MaterialApp.router(
          title: 'Shop App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
          routerConfig: _router,
        ),
      ),
    );
  }
}
