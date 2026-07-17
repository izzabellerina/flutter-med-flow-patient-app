import 'package:flutter/material.dart';

import '../app/theme.dart';

/// การ์ดปุ่มเมนูในหน้าแรก (ไอคอน + ข้อความ) พื้นสีประจำเมนูแบบเต็ม มุมโค้ง เงานุ่ม
/// - [color] สีพื้นการ์ด (ไอคอน/ตัวอักษรเป็นสีขาว)
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    // เงาวางไว้ที่ Container ชั้นนอก (ไม่ใช่ใน Ink) เพื่อให้เงาโค้งตามการ์ด
    // ไม่ถูก Material clip เป็นสี่เหลี่ยม
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.whiteColor.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.whiteColor),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.generalText(
                    16,
                    fonWeight: FontWeight.w700,
                    color: AppTheme.whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
