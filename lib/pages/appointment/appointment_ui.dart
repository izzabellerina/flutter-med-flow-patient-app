import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// หัวข้อ section ในหน้านัดหมาย (เช่น "เลือกวันที่", "รูปแบบ")
class AppointmentSectionTitle extends StatelessWidget {
  final String text;
  const AppointmentSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.generalText(
        18,
        fonWeight: FontWeight.w600,
        color: AppTheme.primaryText,
      ),
    );
  }
}

/// การ์ดมุมโค้ง เงานุ่ม — ใช้ครอบเนื้อหาในหน้านัดหมาย
/// - ปกติ: พื้นขาว + ขอบเทา + เงาจาง
/// - [tinted] = true: พื้น gradient teal อ่อน + เงา teal นุ่ม (โทนเดียวกับการ์ด "นัดหมายที่จะถึง")
class AppointmentCardBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool tinted;

  const AppointmentCardBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: tinted
          ? BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEAF4F7), Color(0xFFD6E9EF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                // ชั้นนอก: teal นวล กระจายกว้าง → การ์ดลอย
                BoxShadow(
                  color: AppTheme.primaryThemeApp.withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: -2,
                  offset: const Offset(0, 14),
                ),
                // ชั้นใน: เงาดำจาง คมใกล้ขอบ
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lineColorD9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      clipBehavior: Clip.antiAlias,
      padding: padding,
      child: child,
    );
  }
}

/// ชิป (chip) ตัวเลือกแบบ outline + ติ๊กถูก — ขนาดพอดีข้อความ ใช้กับ `Wrap`
/// ดีไซน์ต่างจาก [AppointmentChoicePill] (pill พื้นทึบเต็มความกว้าง) อย่างชัดเจน
class AppointmentChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppointmentChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teal = AppTheme.primaryThemeApp;
    return Material(
      color: selected ? teal.withValues(alpha: 0.10) : AppTheme.whiteColor,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? teal : AppTheme.lineColorD9,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ไอคอนถูกโผล่เฉพาะตอนเลือก (แอนิเมชันย่อ-ขยาย)
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.check_rounded, size: 18, color: teal),
                      )
                    : const SizedBox.shrink(),
              ),
              Text(
                label,
                style: AppTheme.generalText(
                  15,
                  fonWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? teal : AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// แคปซูลตัวเลือก (pill) เลือกได้ทีละหลายกลุ่ม — ใช้ใน Step 3 (รูปแบบ)
class AppointmentChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppointmentChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.primaryThemeApp
          : AppTheme.primaryThemeApp.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.generalText(
              16,
              fonWeight: FontWeight.w600,
              color: selected ? AppTheme.whiteColor : AppTheme.primaryThemeApp,
            ),
          ),
        ),
      ),
    );
  }
}
