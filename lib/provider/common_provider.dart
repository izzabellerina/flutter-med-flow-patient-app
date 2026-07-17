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
