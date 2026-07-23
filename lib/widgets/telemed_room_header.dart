import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/appointment_model.dart';

/// การ์ดหัวห้อง Telemed — แสดงข้อมูลแพทย์/นัด + คนไข้ + badge "telemed"
/// ใช้ทั้งหน้า "เข้าห้องตรวจ" และ "ดูรายละเอียด" (โครงเดียวกัน)
class TelemedRoomHeader extends StatelessWidget {
  final AppointmentModel appointment;

  const TelemedRoomHeader({super.key, required this.appointment});

  // teal เข้มสำหรับตัวอักษรหลัก — คอนทราสต์ชัดบนพื้นพาสเทล (ตรงกับการ์ดหน้าแรก)
  static const Color _deepTeal = Color(0xFF2E5A6B);

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.primaryThemeApp; // teal แบรนด์

    return Container(
      decoration: BoxDecoration(
        // โทนพาสเทล teal + เงานวล — เหมือนการ์ด "นัดหมายที่จะถึง" หน้าแรก
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF4F7), Color(0xFFD6E9EF)],
        ),
        borderRadius: BorderRadius.circular(16),
        // เส้นกรอบ teal จาง — ทำให้ขอบคมชัด ไม่ละลายไปกับพื้นหลัง
        border: Border.all(
          color: AppTheme.primaryThemeApp.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: [
          // teal นวล — เก็บให้กระชับ ไม่ฟุ้ง
          BoxShadow(
            color: AppTheme.primaryThemeApp.withValues(alpha: 0.10),
            blurRadius: 12,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.whiteColor,
                child: Icon(Icons.person, color: accent, size: 28),
              ),
              const SizedBox(width: 12),
              // แพทย์ + แผนก + ช่วงเวลา
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 15, color: accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ช่วงเวลา ${appointment.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.generalText(
                              14,
                              color: AppTheme.secondaryText62,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _TelemedBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: _deepTeal.withValues(alpha: 0.12)),
          const SizedBox(height: 10),
          // คนไข้
          Row(
            children: [
              Icon(Icons.badge_outlined,
                  size: 16, color: AppTheme.secondaryText62),
              const SizedBox(width: 6),
              Text(
                'คนไข้ : ',
                style: AppTheme.generalText(
                  15,
                  color: AppTheme.secondaryText62,
                ),
              ),
              Expanded(
                child: Text(
                  appointment.patientName ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.generalText(
                    15,
                    fonWeight: FontWeight.w600,
                    color: _deepTeal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ป้าย "telemed" — สื่อว่าเป็นนัดวิดีโอคอล
class _TelemedBadge extends StatelessWidget {
  const _TelemedBadge();

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.primaryThemeApp;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.call, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            'telemed',
            style: AppTheme.generalText(
              13,
              fonWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
