import 'package:flutter/material.dart';

import '../app/theme.dart';

/// หน้า placeholder สำหรับแท็บที่ยังไม่ทำ feature จริง
/// (ประวัตินัด / ประวัติการวัด)
class PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;

  const PlaceholderPage({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppTheme.secondaryText9A),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.generalText(
                22,
                fonWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กำลังพัฒนา',
              style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
            ),
          ],
        ),
      ),
    );
  }
}
