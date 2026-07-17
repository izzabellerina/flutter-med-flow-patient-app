import 'user_model.dart';

/// ข้อมูลจาก endpoint /me — โครง Map-backed ตาม user-app
class MeModel {
  final Map data;

  MeModel({required this.data});

  UserModel get user => UserModel(data: data['user'] ?? data);
}
