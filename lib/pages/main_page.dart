import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../models/login_model.dart';
import '../models/me_model.dart';
import '../models/user_model.dart';
import '../provider/common_provider.dart';
import 'login_page.dart';

/// หน้า placeholder หลังล็อกอินสำเร็จ — รอต่อฟีเจอร์ patient ต่อไป
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedFlow'),
        actions: [
          IconButton(
            tooltip: 'ออกจากระบบ',
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(loginProvider.notifier).state = LoginModel(data: {});
              ref.read(meProvider.notifier).state = MeModel(data: {});
              ref.read(userProvider.notifier).state = UserModel(data: {});
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 72, color: AppTheme.primaryThemeApp),
            const SizedBox(height: 16),
            Text(
              'เข้าสู่ระบบสำเร็จ',
              style: AppTheme.generalText(
                20,
                fonWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.fullName.isEmpty ? 'ผู้ป่วย' : user.fullName,
              style: AppTheme.generalText(14, color: AppTheme.secondaryText62),
            ),
          ],
        ),
      ),
    );
  }
}
