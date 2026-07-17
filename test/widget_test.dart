import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_flow_patient/main.dart';

void main() {
  testWidgets('Login page renders core fields and social buttons',
      (tester) async {
    await tester.pumpWidget(const MedFlowApp());
    await tester.pump();

    // หัวข้อ + ปุ่มเข้าสู่ระบบ
    expect(find.text('MedFlow'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบ'), findsWidgets);

    // ช่องกรอก username + password
    expect(find.byType(TextField), findsNWidgets(2));

    // ปุ่ม social login
    expect(find.text('เบอร์โทรศัพท์'), findsOneWidget);
    expect(find.text('LINE'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
  });
}
