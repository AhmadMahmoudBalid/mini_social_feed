import 'package:mini_social_feed/features/auth/data/models/auth_response_model.dart';
import 'package:mini_social_feed/features/auth/data/models/user_model.dart';

class RegisterResponseModel {
  final bool status;
  final String message;
  final RegisterData? data;
  final Map<String, dynamic>? errors;

  RegisterResponseModel({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }
}

class RegisterData {
  final UserModel user;
  final Tokens tokens;

  RegisterData({required this.user, required this.tokens});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      user: UserModel.fromJson(json['user']),
      tokens: Tokens.fromJson(json['tokens']),
    );
  }
}
