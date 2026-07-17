import 'package:flutter_riverpod/legacy.dart';

import '../models/login_model.dart';
import '../models/me_model.dart';
import '../models/user_model.dart';

/// State ส่วนกลาง — ตาม flutter-med-flow-user-app
final loginProvider = StateProvider<LoginModel>(
  (ref) => LoginModel(data: {}),
);

final meProvider = StateProvider<MeModel>(
  (ref) => MeModel(data: {}),
);

final userProvider = StateProvider<UserModel>(
  (ref) => UserModel(data: {}),
);

/// ขนาดตัวอักษรของทั้งแอป (accessibility) — A=1.0 / A+=1.15 / A++=1.3
/// ค่าเริ่มต้นถูก override ใน main() ด้วยค่าที่จำไว้ (shared_preferences)
final textScaleProvider = StateProvider<double>((ref) => 1.0);
