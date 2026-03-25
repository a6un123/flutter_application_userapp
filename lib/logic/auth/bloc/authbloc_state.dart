import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final String uid;
  final String email;
  final String name;
  final String role;
  const Authenticated({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });
  @override
  List<Object?> get props => [uid, email, name, role];
}

class Autherror extends AuthState {
  final String message;
  const Autherror({required this.message});
  @override
  List<Object?> get props => [message];
}
