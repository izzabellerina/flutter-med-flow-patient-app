import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_flow_patient/app/theme.dart';
import 'package:med_flow_patient/models/doctor_model.dart';
import 'package:med_flow_patient/widgets/department_selector.dart';

void main() {
  testWidgets('เมนู dropdown ไม่มุดใต้ nav bar แม้อยู่ใน SafeArea', (tester) async {
    const screenH = 700.0;
    const navBar = 48.0;
    tester.view.physicalSize = const Size(400, screenH);
    tester.view.devicePixelRatio = 1.0;
    // จำลอง nav bar — ต้องตั้งทั้ง padding (ให้ SafeArea กิน) และ viewPadding (โค้ดอ่าน)
    tester.view.padding = const FakeViewPadding(bottom: navBar);
    tester.view.viewPadding = const FakeViewPadding(bottom: navBar);
    addTearDown(tester.view.reset);

    Department? sel;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(
        // ห่อ SafeArea เหมือนหน้านัดหมายจริง → viewPadding.bottom ถูก zero ใน context ลูก
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 360),
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
                const SizedBox(height: 600),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DepartmentSelector));
    await tester.pumpAndSettle();

    // เมนูต้องจบเหนือ nav bar (ไม่โดนบัง)
    final listRect = tester.getRect(find.byType(ListView));
    expect(listRect.bottom, lessThanOrEqualTo(screenH - navBar));
  });
}
