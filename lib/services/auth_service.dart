import 'dart:developer';

import '../models/login_model.dart';
import '../models/me_model.dart';
import '../models/response_model.dart';

/// บริการ Auth
///
/// ⚠️ ตอนนี้ API ฝั่ง patient ยังไม่มี — ทุกเมธอด**คืน mock data**
/// (ไม่ยิงเน็ตจริง) เพื่อให้ไล่ flow หน้า login ได้ครบ.
/// เมื่อ API พร้อม ให้แทนที่ส่วน mock ด้วย http request (ดู [MedConfig]).
class AuthService {
  /// จำลอง network latency เล็กน้อยให้เห็น loading state
  static const _mockDelay = Duration(milliseconds: 600);

  static Future<ResponseModel<LoginModel>> login({
    required String username,
    required String password,
  }) async {
    log("login (MOCK) username=$username");
    await Future.delayed(_mockDelay);

    // MOCK: รับทุก username/password ที่ไม่ว่าง แล้วคืนผู้ใช้ปลอม
    if (username.isEmpty || password.isEmpty) {
      return ResponseModel(
        data: LoginModel(data: {}),
        responseEnum: ResponseEnum.fail,
      );
    }

    final mock = {
      'access_token': 'mock-access-token',
      'refresh_token': 'mock-refresh-token',
      'user': {
        'id': 'mock-1',
        'hn': '123213312',
        'username': username,
        'full_name': 'Thanawat Kaewphrom',
        'phone': '0800000000',
        'email': '$username@example.com',
      },
    };

    return ResponseModel(
      data: LoginModel(data: mock),
      responseEnum: ResponseEnum.success,
    );
  }

  /// MOCK: คืนข้อมูลผู้ใช้ปลอม (ปกติจะยิง GET /me ด้วย access token)
  static Future<ResponseModel<MeModel>> me() async {
    log("me (MOCK)");
    await Future.delayed(_mockDelay);

    final mock = {
      'user': {
        'id': 'mock-1',
        'hn': '123213312',
        'username': 'patient',
        'full_name': 'Thanawat Kaewphrom',
        'phone': '0800000000',
        'email': 'patient@example.com',
      },
    };

    return ResponseModel(
      data: MeModel(data: mock),
      responseEnum: ResponseEnum.success,
    );
  }
}
