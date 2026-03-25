import 'package:flutter/material.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_state.dart';
import 'package:flutter_application_userapp/router/refreshstream.dart';
import 'package:flutter_application_userapp/view/adminregistrationscreen/adminregitraionscreen.dart';
import 'package:flutter_application_userapp/view/homescreen/homescreen.dart';
import 'package:flutter_application_userapp/view/loginscreen/loginscreen.dart';
import 'package:flutter_application_userapp/view/registrationscreen/registrationscreen.dart';
import 'package:flutter_application_userapp/view/splashscrenn/splashscreen.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',

    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      // Never redirect away from splash
      if (location == '/') return null;

      final isPublicRoute = [
        '/login',
        '/register',
        '/admin-register',
      ].contains(location);

      // Not logged in
      if (authState is Unauthenticated || authState is AuthInitial) {
        if (isPublicRoute) return null;
        return '/login';
      }

      // Logged in
      if (authState is Authenticated) {
        // Don't let logged-in users visit login/register
        if (isPublicRoute) {
          return authState.role == 'admin' ? '/admin' : '/home';
        }
        // Admin trying to visit user home
        if (authState.role == 'admin' && location == '/home') {
          return '/admin';
        }
        // User trying to visit admin
        if (authState.role == 'user' && location == '/admin') {
          return '/home';
        }
      }

      return null;
    },

    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    routes: [
      // Splash
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Login
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // Register
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Admin Register
      GoRoute(
        path: '/admin-register',
        builder: (context, state) => const AdminRegisterScreen(),
      ),

      // User Home
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

      // Admin Dashboard
      GoRoute(path: '/admin', builder: (context, state) => const HomeScreen()),
    ],
  );
}

// Temporary admin screen — replace with real admin app later
class AdminPlaceholderScreen extends StatelessWidget {
  const AdminPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Admin App\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
