import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_flow_patient/app/theme.dart';
import 'package:med_flow_patient/pages/appointment/new_appointment_page.dart';
import 'package:med_flow_patient/widgets/department_selector.dart';

void main() {
  Widget wrap() => MaterialApp(
        theme: AppTheme.theme,
        home: const NewAppointmentPage(),
      );

  testWidgets('เดิน flow นัดหมายครบ 3 step จนถึงยืนยัน', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // ── Step 1 ────────────────────────────────────────────────
    expect(find.text('นัดหมายใหม่'), findsOneWidget);
    expect(find.text('เลือกวันที่'), findsOneWidget);
    expect(find.text('กรุณาเลือกแผนกก่อน'), findsOneWidget);

    // ปุ่มถัดไปยังกดไม่ได้ (ยังไม่เลือกแผนก/แพทย์)
    final nextBtn = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'ถัดไป'),
    );
    expect(nextBtn.onPressed, isNull);

    // เลือกแผนก "ทันตกรรม" ผ่าน bottom sheet
    final deptField = find.byType(DepartmentSelector);
    await tester.ensureVisible(deptField);
    await tester.pumpAndSettle();
    await tester.tap(deptField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ทันตกรรม').last);
    await tester.pumpAndSettle();

    // เลือกแพทย์ในแผนกนั้น
    final doctor = find.text('นพ. ธนา รักษ์ดี');
    expect(doctor, findsOneWidget);
    await tester.ensureVisible(doctor);
    await tester.pumpAndSettle();
    await tester.tap(doctor);
    await tester.pumpAndSettle();

    // ถัดไปกดได้แล้ว → ไป Step 2
    await tester.tap(find.widgetWithText(ElevatedButton, 'ถัดไป'));
    await tester.pumpAndSettle();

    // ── Step 2 ────────────────────────────────────────────────
    expect(find.text('ว่าง'), findsWidgets);
    expect(find.text('ไม่ว่าง'), findsWidgets);
    // เลือกช่องเวลาแรก (ว่าง = 09:30)
    final slot = find.text('09:30');
    await tester.ensureVisible(slot);
    await tester.pumpAndSettle();
    await tester.tap(slot);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'ถัดไป'));
    await tester.pumpAndSettle();

    // ── Step 3 ────────────────────────────────────────────────
    expect(find.text('รูปแบบ'), findsOneWidget);
    expect(find.text('โปรแกรม'), findsOneWidget);

    // ปุ่มยืนยันยังกดไม่ได้จนกว่าจะเลือกรูปแบบ+โปรแกรม
    var confirm = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'ยืนยัน'),
    );
    expect(confirm.onPressed, isNull);

    await tester.tap(find.text('Telemed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('พบแพทย์,ปรึกษา'));
    await tester.pumpAndSettle();

    confirm = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'ยืนยัน'),
    );
    expect(confirm.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(ElevatedButton, 'ยืนยัน'));
    await tester.pumpAndSettle();

    // ── Modal สรุป ────────────────────────────────────────────
    expect(find.text('สรุปการนัดหมาย'), findsOneWidget);
    expect(find.text('นพ. ธนา รักษ์ดี\nแผนกทันตกรรม'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'ยืนยันการนัดหมาย'));
    await tester.pumpAndSettle();

    // ── Success dialog ────────────────────────────────────────
    expect(find.text('ส่งคำขอนัดหมายแล้ว'), findsOneWidget);
    expect(find.text('เสร็จสิ้น'), findsOneWidget);
  });
}
