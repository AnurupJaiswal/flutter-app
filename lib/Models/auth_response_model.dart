import 'package:lala_ai/Models/user_model.dart';

class AuthResponseModel {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  AuthResponseModel({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Determine where the payload data is located.
    // Sometimes backend nests inside "data" object, sometimes not.
    final payload = json['data'] ?? json;

    return AuthResponseModel(
      success: json['success'] == true || (json['statusCode'] != null && json['statusCode'] >= 200 && json['statusCode'] < 300) || json['status'] == 'success',
      message: json['message']?.toString(),
      accessToken: payload['accessToken']?.toString() ?? payload['token']?.toString(),
      refreshToken: payload['refreshToken']?.toString(),
      user: payload['user'] != null ? UserModel.fromJson(payload['user']) : null,
    );
  }
}
