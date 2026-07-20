import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/theme.dart';
import 'app/th_buddhist_localizations.dart';
import 'pages/login_page.dart';
import 'provider/common_provider.dart';
import 'services/configuration.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ใช้ฟอนต์ที่ bundle มาเท่านั้น — ไม่ fetch runtime (กันแอปค้างตอนไม่มีเน็ต)
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = MyHttpOverrides();
  // โหลดขนาดตัวอักษรที่ผู้ใช้เคยตั้งไว้ แล้ว override provider ก่อน runApp (กันจอกระพริบ)
  final textScale = await LocalStorageService.getTextScale();
  runApp(
    ProviderScope(
      overrides: [textScaleProvider.overrideWith((ref) => textScale)],
      child: const MedFlowApp(),
    ),
  );
}

class MedFlowApp extends ConsumerWidget {
  const MedFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MedFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // ล็อกทั้งแอปเป็นภาษาไทย — ปฏิทิน/date picker แสดงเดือน+ชื่อวันย่อเป็นไทย
      locale: const Locale('th'),
      supportedLocales: const [Locale('th')],
      // ใช้ delegate Material แบบ พ.ศ. แทนตัวมาตรฐาน (ปฏิทินแสดงปีพุทธศักราช)
      localizationsDelegates: const [
        thaiBuddhistMaterialDelegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginPage(),
      // ปรับขนาดตัวอักษรทั้งแอปตามค่าที่ผู้ใช้เลือก (accessibility)
      builder: (context, child) {
        final scale = ref.watch(textScaleProvider);
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
    );
  }
}
