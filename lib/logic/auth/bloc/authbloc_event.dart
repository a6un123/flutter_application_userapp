import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class Loginsubmit extends AuthEvent {
  final String email;
  final String password;
  const Loginsubmit({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmit extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const RegisterSubmit({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class AdminRegisterSubmit extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AdminRegisterSubmit({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class LogoutEvent extends AuthEvent {}
