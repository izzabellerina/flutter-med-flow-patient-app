import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/theme.dart';
import 'pages/login_page.dart';
import 'services/configuration.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // ใช้ฟอนต์ที่ bundle มาเท่านั้น — ไม่ fetch runtime (กันแอปค้างตอนไม่มีเน็ต)
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = MyHttpOverrides();
  runApp(const ProviderScope(child: MedFlowApp()));
}

class MedFlowApp extends StatelessWidget {
  const MedFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginPage(),
    );
  }
}
