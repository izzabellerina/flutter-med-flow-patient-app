import 'dart:io';

/// Central config for talking to the MedFlow backend.
///
/// NOTE: ตอนนี้ API ฝั่ง patient ยังไม่มี — auth ใช้ mock data ไปก่อน
/// (ดู [AuthService]). คลาสนี้คงไว้เพื่อพร้อมเสียบ endpoint จริงภายหลัง.
class MedConfig {
  // Production server (เว็บฝั่ง patient เชื่อมกับที่นี่)
  static String server = "https://med3.medflow.in.th";

  static String https({String? service, required String path}) {
    final servicePath = (service == null || service.isEmpty) ? '' : '$service/';
    return "$server/api/api/v1/$servicePath$path";
  }

  static String httpsWithPublic({
    required String service,
    required String path,
  }) {
    return "$server/api/api/public/$service/$path";
  }
}

class PortConfig {
  static const String authPort = "auth";
  static const String telemedPort = "telemed";
  static const String clinicPort = "clinical";
  static const String doctorPort = "doctor";
}

/// อนุญาต self-signed cert (ตาม user-app) — ใช้ตอนต่อ API จริงภายหลัง.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
