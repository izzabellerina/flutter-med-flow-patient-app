import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/doctor_model.dart';

/// การ์ดแสดงข้อมูลแพทย์ (avatar + ชื่อ + แผนก + ช่วงเวลาออกตรวจ)
/// - ไม่เลือก: **พื้นขาว** + ขอบเทา + ตัวอักษรเข้ม
/// - เลือก: teal filled + ตัวอักษร/ไอคอนขาว + ติ๊กถูก (โดดเด่นจากใบขาว)
/// - โหมดสรุป (step 2/3): ไม่ส่ง [onTap] → แสดงเป็นพื้นขาว เฉย ๆ
class DoctorInfoCard extends StatelessWidget {
  final Doctor doctor;
  final bool selected;
  final VoidCallback? onTap;

  const DoctorInfoCard({
    super.key,
    required this.doctor,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final white = AppTheme.whiteColor;
    // teal เข้มสำหรับการ์ดที่เลือก
    const selectedTeal = Color(0xFF386577);
    // ไม่เลือก → ขาวปกติ/ตัวอักษรเข้ม · เลือก → teal เข้ม/ตัวอักษรขาว
    final onCard = selected ? white : AppTheme.primaryText;
    final subColor = selected
        ? white.withValues(alpha: 0.9)
        : AppTheme.secondaryText62;

    final card = Container(
      decoration: BoxDecoration(
        color: selected ? AppTheme.primaryThemeApp : white,
        borderRadius: BorderRadius.circular(16),
        border: selected
            ? null
            : Border.all(color: AppTheme.lineColorD9, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: selected
                ? selectedTeal.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: selected ? 18 : 12,
            spreadRadius: -2,
            offset: Offset(0, selected ? 8 : 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: selected
                ? white.withValues(alpha: 0.22)
                : AppTheme.primaryThemeApp.withValues(alpha: 0.15),
            child: Icon(
              Icons.person,
              size: 30,
              color: selected ? white : AppTheme.primaryThemeApp,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: AppTheme.generalText(
                    18,
                    fonWeight: FontWeight.w700,
                    color: onCard,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'แผนก${doctor.departmentName}',
                  style: AppTheme.generalText(15, color: subColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'ช่วงเวลา ${doctor.workRange}',
                  style: AppTheme.generalText(15, color: subColor),
                ),
              ],
            ),
          ),
          // ติ๊กถูกมุมขวาเมื่อถูกเลือก — วงขาว + check teal เข้ม ให้ตัดกับพื้น teal
          if (onTap != null && selected) ...[
            const SizedBox(width: 8),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle, color: white),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                size: 18,
                color: selectedTeal,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}
