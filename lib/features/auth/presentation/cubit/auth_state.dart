part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponseModel authResponse;

  const AuthSuccess(this.authResponse);
}

class RegisterSuccess extends AuthState {
  final RegisterResponseModel registerResponse;

  const RegisterSuccess(this.registerResponse);
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}
