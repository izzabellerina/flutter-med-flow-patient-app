import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/appointment_model.dart';

/// การ์ดนัดหมายในหน้าแรก — โทนพาสเทล teal อ่อน (ตัวอักษรสีแบรนด์เข้ม)
/// ปุ่ม "เลื่อนนัด" / "ดูรายละเอียด" ยังเป็น stub รอต่อ feature จริง
class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onReschedule;
  final VoidCallback onViewDetail;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onReschedule,
    required this.onViewDetail,
  });

  // teal เข้มสำหรับตัวอักษรหลัก ให้คอนทราสต์ชัดบนพื้นพาสเทล
  static const Color _deepTeal = Color(0xFF2E5A6B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF4F7), Color(0xFFD6E9EF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // ชั้นนอก: teal นวล กระจายกว้าง → การ์ดลอยมีมิติ
          BoxShadow(
            color: AppTheme.primaryThemeApp.withValues(alpha: 0.22),
            blurRadius: 28,
            spreadRadius: -2,
            offset: const Offset(0, 14),
          ),
          // ชั้นใน: เงาดำจาง คมใกล้ขอบ → เพิ่มน้ำหนัก
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // แถวหมอ + badge ประเภทนัด (มุมขวาบน)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.whiteColor,
                child: Icon(Icons.person, color: AppTheme.primaryThemeApp),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      appointment.doctorName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.generalText(
                        18,
                        fonWeight: FontWeight.w700,
                        color: _deepTeal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.generalText(
                        15,
                        color: AppTheme.secondaryText62,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TypeBadge(type: appointment.type),
            ],
          ),
          const SizedBox(height: 14),
          // วันที่ + เวลา
          _infoRow(Icons.calendar_today_outlined, appointment.date),
          const SizedBox(height: 8),
          _infoRow(Icons.access_time, appointment.time),
          const SizedBox(height: 16),
          // ปุ่ม
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReschedule,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    backgroundColor: AppTheme.whiteColor,
                    side: BorderSide(color: AppTheme.primaryThemeApp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'เลื่อนนัด',
                    style: AppTheme.generalText(
                      16,
                      fonWeight: FontWeight.w600,
                      color: AppTheme.primaryThemeApp,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryThemeApp,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'ดูรายละเอียด',
                    style: AppTheme.generalText(
                      16,
                      fonWeight: FontWeight.w600,
                      color: AppTheme.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryThemeApp),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.generalText(16, color: AppTheme.primaryText),
          ),
        ),
      ],
    );
  }
}

/// badge ประเภทนัด (Telemed / มาที่ รพ.) — pill สี + ไอคอน
class _TypeBadge extends StatelessWidget {
  final AppointmentType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (type) {
      AppointmentType.telemed => (
          const Color(0xFF8B5CF6), // ม่วง
          Icons.videocam_rounded,
        ),
      AppointmentType.onsite => (
          const Color(0xFF2E7D8F), // teal เข้ม
          Icons.local_hospital_rounded,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.whiteColor),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: AppTheme.generalText(
              12,
              fonWeight: FontWeight.w700,
              color: AppTheme.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
