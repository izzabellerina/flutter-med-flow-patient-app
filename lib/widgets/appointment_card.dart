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
          // แถวหมอ
          Row(
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
