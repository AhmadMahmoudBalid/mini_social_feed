import 'user_model.dart';

class AuthResponseModel {
  final bool status;
  final String message;
  final AuthData? data;

  AuthResponseModel({required this.status, required this.message, this.data});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

class AuthData {
  final UserModel user;
  final Tokens tokens;

  AuthData({required this.user, required this.tokens});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: UserModel.fromJson(json['user']),
      tokens: Tokens.fromJson(json['tokens']),
    );
  }
}

class Tokens {
  final String tokenType;
  final String accessToken;
  final String accessTokenExpiresAt;
  final String refreshToken;
  final String refreshTokenExpiresAt;

  Tokens({
    required this.tokenType,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      tokenType: json['token_type'],
      accessToken: json['access_token'],
      accessTokenExpiresAt: json['access_token_expires_at'],
      refreshToken: json['refresh_token'],
      refreshTokenExpiresAt: json['refresh_token_expires_at'],
    );
  }
}
