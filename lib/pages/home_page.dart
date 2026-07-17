import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../models/appointment_model.dart';
import '../provider/common_provider.dart';
import '../widgets/appointment_card.dart';
import '../widgets/menu_tile.dart';

/// หน้าแรก (Home Dashboard) — แท็บแรกใน MainPage shell
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final appointments = AppointmentModel.mockUpcoming;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Header(
                hn: user.hn.isEmpty ? '-' : user.hn,
                fullName: user.fullName.isEmpty ? 'ผู้ป่วย' : user.fullName,
                onNotification: () => _comingSoon(context, 'การแจ้งเตือน'),
              ),
            ),
            const SizedBox(height: 24),

            // ── นัดหมายที่จะถึง ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'นัดหมายที่จะถึง',
                style: AppTheme.generalText(
                  20,
                  fonWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _UpcomingAppointments(
              appointments: appointments,
              onReschedule: (a) =>
                  _comingSoon(context, 'เลื่อนนัด — ${a.doctorName}'),
              onViewDetail: (a) =>
                  _comingSoon(context, 'ดูรายละเอียด — ${a.doctorName}'),
            ),
            const SizedBox(height: 28),

            // ── เมนู 2×2 ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'เมนู',
                style: AppTheme.generalText(
                  20,
                  fonWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _MenuGrid(
                onTap: (label) => _comingSoon(context, label),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — กำลังพัฒนา')),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String hn;
  final String fullName;
  final VoidCallback onNotification;

  const _Header({
    required this.hn,
    required this.fullName,
    required this.onNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppTheme.primaryThemeApp.withValues(alpha: 0.15),
          child: Icon(Icons.person, size: 30, color: AppTheme.primaryThemeApp),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HN : $hn',
                style: AppTheme.generalText(
                  15,
                  color: AppTheme.secondaryText62,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'สวัสดี, $fullName',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.generalText(
                  20,
                  fonWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ),
        // กระดิ่งแจ้งเตือน
        Material(
          color: AppTheme.whiteColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onNotification,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── นัดหมายที่จะถึง (carousel) ────────────────────────────────────────────
class _UpcomingAppointments extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final void Function(AppointmentModel) onReschedule;
  final void Function(AppointmentModel) onViewDetail;

  const _UpcomingAppointments({
    required this.appointments,
    required this.onReschedule,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _EmptyState(),
      );
    }

    final cardWidth = MediaQuery.of(context).size.width * 0.82;
    // ใช้ IntrinsicHeight + Row แทน ListView สูงตายตัว → การ์ดสูงตามเนื้อหา
    // (ปลอดภัยเมื่อผู้ใช้ขยายฟอนต์ระบบ ไม่ overflow) และการ์ดทุกใบสูงเท่ากัน
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Clip.none + เผื่อ padding แนวตั้ง เพื่อไม่ให้เงาบน-ล่างของการ์ดถูกตัด
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < appointments.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              SizedBox(
                width: cardWidth,
                child: AppointmentCard(
                  appointment: appointments[i],
                  onReschedule: () => onReschedule(appointments[i]),
                  onViewDetail: () => onViewDetail(appointments[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.event_available_outlined,
              size: 48, color: AppTheme.secondaryText9A),
          const SizedBox(height: 12),
          Text(
            'ยังไม่มีนัดหมายที่จะถึง',
            style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
          ),
        ],
      ),
    );
  }
}

// ── เมนู 2×2 ──────────────────────────────────────────────────────────────
class _MenuGrid extends StatelessWidget {
  final void Function(String label) onTap;

  const _MenuGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // (ไอคอน, ป้าย, สีพื้นการ์ด)
    const items = <(IconData, String, Color)>[
      (Icons.event_note_outlined, 'นัดหมาย', Color(0xFF3B82F6)), // ฟ้า
      (Icons.verified_user_outlined, 'สิทธิ์การรักษา', Color(0xFF22A45D)), // เขียว
      (Icons.medication_outlined, 'รายการยา', Color(0xFFE0870B)), // ส้ม
      (Icons.video_camera_front_outlined, 'Telemed', Color(0xFF8B5CF6)), // ม่วง
    ];

    // 2 แถว × 2 คอลัมน์ ด้วย IntrinsicHeight+Expanded → การ์ดสูงตามเนื้อหา
    // (ไม่ตายตัวแบบ childAspectRatio) รองรับการขยายฟอนต์โดยไม่ overflow
    Widget tile((IconData, String, Color) it) => MenuTile(
          icon: it.$1,
          label: it.$2,
          color: it.$3,
          onTap: () => onTap(it.$2),
        );

    Widget row((IconData, String, Color) left, (IconData, String, Color) right) =>
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tile(left)),
              const SizedBox(width: 14),
              Expanded(child: tile(right)),
            ],
          ),
        );

    return Column(
      children: [
        row(items[0], items[1]),
        const SizedBox(height: 14),
        row(items[2], items[3]),
      ],
    );
  }
}
