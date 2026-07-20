import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_flow_patient/app/theme.dart';
import 'package:med_flow_patient/models/doctor_model.dart';
import 'package:med_flow_patient/widgets/department_selector.dart';

void main() {
  testWidgets('เลื่อนหน้าข้างนอก → dropdown ยังเปิด (เลื่อนตาม) · แตะข้างนอก → ปิด',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Department? sel;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 200),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StatefulBuilder(
                  builder: (c, setState) => DepartmentSelector(
                    departments: Department.mock,
                    selected: sel,
                    onChanged: (d) => setState(() => sel = d),
                  ),
                ),
              ),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final fieldYBefore = tester.getTopLeft(find.byType(DepartmentSelector)).dy;

    await tester.tap(find.byType(DepartmentSelector));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);

    // เลื่อนหน้าข้างนอก → หน้าเลื่อน แต่ dropdown "ยังเปิด"
    await tester.dragFrom(const Offset(200, 80), const Offset(0, -120));
    await tester.pumpAndSettle();
    final fieldYAfter = tester.getTopLeft(find.byType(DepartmentSelector)).dy;
    expect(fieldYAfter, lessThan(fieldYBefore)); // หน้าเลื่อนจริง
    expect(find.byType(ListView), findsOneWidget); // dropdown ยังเปิด

    // แตะข้างนอก (พื้นที่ว่างด้านบน) → ปิด
    await tester.tapAt(const Offset(200, 30));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsNothing);
  });
}
