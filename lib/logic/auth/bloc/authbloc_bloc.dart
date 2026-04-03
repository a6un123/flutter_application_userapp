import 'package:flutter_application_userapp/data/repositiories/authrepostiories/authrepositery.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_event.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuth);
    on<Loginsubmit>(_onLogin);
    on<RegisterSubmit>(_onRegister);
    on<AdminRegisterSubmit>(_onAdminRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuth(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      final role = await _authRepository.getUserRole(user.uid);
      emit(
        Authenticated(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          role: role,
        ),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  // In _onLogin after emitting Authenticated state
  // Add this to load the user's cart
  Future<void> _onLogin(Loginsubmit event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        final role = await _authRepository.getUserRole(user.uid);
        emit(
          Authenticated(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
            role: role,
          ),
        );
      }
    } catch (e) {
      emit(Autherror(message: _friendlyError(e.toString())));
    }
  }

  Future<void> _onRegister(
    RegisterSubmit event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(
          Authenticated(
            uid: user.uid,
            email: user.email ?? '',
            name: event.name,
            role: 'user',
          ),
        );
      }
    } catch (e) {
      emit(Autherror(message: _friendlyError(e.toString())));
    }
  }

  Future<void> _onAdminRegister(
    AdminRegisterSubmit event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.registerAdmin(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(
          Authenticated(
            uid: user.uid,
            email: user.email ?? '',
            name: event.name,
            role: 'admin',
          ),
        );
      }
    } catch (e) {
      emit(Autherror(message: _friendlyError(e.toString())));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(Unauthenticated());
  }

  String _friendlyError(String error) {
    if (error.contains('user-not-found'))
      return 'No account found with this email';
    if (error.contains('wrong-password')) return 'Incorrect password';
    if (error.contains('email-already-in-use'))
      return 'Email already registered';
    if (error.contains('weak-password')) return 'Password is too weak';
    if (error.contains('invalid-email')) return 'Invalid email address';
    if (error.contains('network-request-failed'))
      return 'No internet connection';
    if (error.contains('too-many-requests'))
      return 'Too many attempts. Try later';
    return 'Something went wrong. Please try again';
  }
}
