import 'package:mini_social_feed/features/auth/data/models/user_model.dart';

class ProfileResponse {
  final bool status;
  final String message;
  final UserModel data;

  ProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'],
      message: json['message'],
      data: UserModel.fromJson(json['data']),
    );
  }
}
