import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../models/login_model.dart';
import '../models/me_model.dart';
import '../models/user_model.dart';
import '../provider/common_provider.dart';
import '../services/local_storage_service.dart';
import 'login_page.dart';

/// แท็บ "ผู้ใช้งาน" — ข้อมูลผู้ใช้ + ตั้งค่าขนาดตัวอักษร (accessibility) + ออกจากระบบ
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  // ตัวเลือกขนาดตัวอักษร (label, ค่า scale)
  static const List<({String label, double scale})> _textScaleOptions = [
    (label: 'A', scale: 1.0),
    (label: 'A+', scale: 1.15),
    (label: 'A++', scale: 1.3),
  ];

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(loginProvider.notifier).state = LoginModel(data: {});
    ref.read(meProvider.notifier).state = MeModel(data: {});
    ref.read(userProvider.notifier).state = UserModel(data: {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _setScale(WidgetRef ref, double scale) async {
    ref.read(textScaleProvider.notifier).state = scale;
    await LocalStorageService.saveTextScale(scale);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final scale = ref.watch(textScaleProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── ข้อมูลผู้ใช้ ─────────────────────────────────────────
            _userCard(user),
            const SizedBox(height: 20),

            // ── ขนาดตัวอักษร ────────────────────────────────────────
            _sectionTitle('ขนาดตัวอักษร'),
            const SizedBox(height: 12),
            _textScaleCard(ref, scale),
            const SizedBox(height: 28),

            // ── ออกจากระบบ ─────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () => _logout(context, ref),
              icon: Icon(Icons.logout, color: AppTheme.errorColor),
              label: Text(
                'ออกจากระบบ',
                style: AppTheme.generalText(
                  16,
                  fonWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: BorderSide(color: AppTheme.errorColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: AppTheme.generalText(
          20,
          fonWeight: FontWeight.w600,
          color: AppTheme.primaryText,
        ),
      );

  Widget _card({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      );

  Widget _userCard(UserModel user) {
    final name = user.fullName.isEmpty ? 'ผู้ป่วย' : user.fullName;
    final hn = user.hn.isEmpty ? '-' : user.hn;
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryThemeApp.withValues(alpha: 0.15),
            child:
                Icon(Icons.person, size: 34, color: AppTheme.primaryThemeApp),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.generalText(
                    18,
                    fonWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'HN : $hn',
                  style: AppTheme.generalText(
                    15,
                    color: AppTheme.secondaryText62,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textScaleCard(WidgetRef ref, double current) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เลือกขนาดที่อ่านสบายที่สุด',
            style: AppTheme.generalText(15, color: AppTheme.secondaryText62),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < _textScaleOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _scaleButton(ref, _textScaleOptions[i], current),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _scaleButton(
    WidgetRef ref,
    ({String label, double scale}) option,
    double current,
  ) {
    final selected = (current - option.scale).abs() < 0.001;
    return Material(
      color: selected
          ? AppTheme.primaryThemeApp
          : AppTheme.primaryThemeApp.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _setScale(ref, option.scale),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Text(
            option.label,
            // ขนาดตัวอักษรบนปุ่มสะท้อนระดับที่จะได้ (A เล็ก → A++ ใหญ่)
            style: AppTheme.generalText(
              14 + option.scale * 6,
              fonWeight: FontWeight.w700,
              color:
                  selected ? AppTheme.whiteColor : AppTheme.primaryThemeApp,
            ),
          ),
        ),
      ),
    );
  }
}
