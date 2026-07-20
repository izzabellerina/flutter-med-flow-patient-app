import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_flow_patient/app/theme.dart';
import 'package:med_flow_patient/models/doctor_model.dart';
import 'package:med_flow_patient/widgets/department_selector.dart';

void main() {
  testWidgets('เมนู dropdown แผนกอยู่ในขอบเขตจอ + เลื่อนได้ เมื่อช่องอยู่ค่อนล่าง',
      (tester) async {
    const screenH = 600.0;
    await tester.binding.setSurfaceSize(const Size(400, screenH));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Department? sel;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(
        body: Padding(
          // ดันช่องไปเกือบล่างจอ → ถ้ากางลงจะล้นจอ ต้องกางขึ้น/จำกัดความสูง
          padding: const EdgeInsets.fromLTRB(20, 470, 20, 20),
          child: Align(
            alignment: Alignment.topCenter,
            child: StatefulBuilder(
              builder: (c, setState) => DepartmentSelector(
                departments: Department.mock,
                selected: sel,
                onChanged: (d) => setState(() => sel = d),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DepartmentSelector));
    await tester.pumpAndSettle();

    // เมนู (ListView) ต้องอยู่ในขอบเขตจอทั้งบนและล่าง (ไม่ตกหลัง nav bar)
    final listRect = tester.getRect(find.byType(ListView));
    expect(listRect.top, greaterThanOrEqualTo(0.0));
    expect(listRect.bottom, lessThanOrEqualTo(screenH));

    // เลือกแผนกได้ (แตะนอกเมนูเพื่อปิดผ่าน barrier ก็ได้ แต่ทดสอบเลือกจริง)
    await tester.tap(find.text('อายุรกรรม'));
    await tester.pumpAndSettle();
    expect(sel?.id, 'internal');
  });
}
