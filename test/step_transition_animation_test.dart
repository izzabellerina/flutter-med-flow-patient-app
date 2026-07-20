import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_flow_patient/app/theme.dart';
import 'package:med_flow_patient/pages/appointment/new_appointment_page.dart';
import 'package:med_flow_patient/widgets/department_selector.dart';

void main() {
  testWidgets('มี transition (slide+fade) ตอนเปลี่ยน step', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      home: const NewAppointmentPage(),
    ));
    await tester.pumpAndSettle();

    // เตรียม step 1 ให้พร้อมกด ถัดไป
    final deptField = find.byType(DepartmentSelector);
    await tester.ensureVisible(deptField);
    await tester.pumpAndSettle();
    await tester.tap(deptField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ทันตกรรม').last);
    await tester.pumpAndSettle();
    final doctor = find.text('นพ. ธนา รักษ์ดี');
    await tester.ensureVisible(doctor);
    await tester.pumpAndSettle();
    await tester.tap(doctor);
    await tester.pumpAndSettle();

    // ยืนยันตอนนิ่ง: อยู่ step 1 (มี "เลือกวันที่"), ยังไม่มี slot ของ step 2
    expect(find.text('เลือกวันที่'), findsOneWidget);

    // กด ถัดไป แล้ว pump แค่กลางทาง (150ms < 300ms) → ต้องกำลัง transition
    await tester.tap(find.widgetWithText(ElevatedButton, 'ถัดไป'));
    await tester.pump(); // เริ่ม animation
    await tester.pump(const Duration(milliseconds: 150));

    // ระหว่าง transition มี SlideTransition + FadeTransition และเนื้อหา 2 step ซ้อนกัน
    expect(find.byType(SlideTransition), findsWidgets);
    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.text('เลือกวันที่'), findsOneWidget); // step 1 กำลังจางออก
    expect(find.text('ว่าง'), findsWidgets); // step 2 กำลังจางเข้า

    // จบ animation → เหลือ step 2 เท่านั้น
    await tester.pumpAndSettle();
    expect(find.text('เลือกวันที่'), findsNothing);
    expect(find.text('ว่าง'), findsWidgets);
  });
}
