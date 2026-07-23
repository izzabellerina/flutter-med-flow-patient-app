import 'package:flutter/material.dart';

import '../app/theme.dart';

/// แถบแท็ปเลื่อนซ้าย-ขวาได้ (reusable) — ใช้ทั้งแท็ปหลักและแท็ปย่อยในห้อง Telemed
/// [primary] = true → สไตล์แท็ปหลัก (ตัวหนา + เส้นใต้), false → แท็ปย่อย(pill เล็ก)
class TelemedTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool primary;

  const TelemedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return primary ? _buildPrimary() : _buildSecondary();
  }

  /// แท็ปหลัก — ข้อความ + เส้นใต้ตัวที่เลือก, มีเส้นคั่นล่างเต็มแนว
  Widget _buildPrimary() {
    final accent = AppTheme.primaryThemeApp;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.lineColorD9)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = i == selectedIndex;
            return InkWell(
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? accent : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: AppTheme.generalText(
                    15,
                    fonWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? accent : AppTheme.secondaryText62,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// แท็ปย่อย — pill เล็ก เลื่อนแนวนอน
  Widget _buildSecondary() {
    final accent = AppTheme.primaryThemeApp;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: selected
                  ? accent.withValues(alpha: 0.12)
                  : AppTheme.whiteColor,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelected(i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? accent : AppTheme.lineColorD9,
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    style: AppTheme.generalText(
                      14,
                      fonWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? accent : AppTheme.secondaryText62,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
