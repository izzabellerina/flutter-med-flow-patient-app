/// ข้อมูลผู้ใช้ (patient) — โครง Map-backed ตาม user-app
class UserModel {
  final Map data;

  UserModel({required this.data});

  String get id => (data['id'] ?? '').toString();
  String get hn => (data['hn'] ?? '').toString();
  String get username => data['username'] ?? '';
  String get fullName => data['full_name'] ?? data['name'] ?? '';
  String get phone => data['phone'] ?? '';
  String get email => data['email'] ?? '';
  String get avatarUrl => data['avatar_url'] ?? '';
}
