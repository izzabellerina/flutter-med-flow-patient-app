import 'user_model.dart';

/// ผลการล็อกอิน — โครง Map-backed ตาม user-app
class LoginModel {
  final Map data;

  LoginModel({required this.data});

  String get accessToken => data['access_token'] ?? '';
  String get refreshToken => data['refresh_token'] ?? '';
  UserModel get user => UserModel(data: data['user'] ?? {});
}
