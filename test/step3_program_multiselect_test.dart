import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_flow_patient/app/theme.dart';
import 'package:med_flow_patient/models/doctor_model.dart';
import 'package:med_flow_patient/pages/appointment/steps/step3_details.dart';

void main() {
  testWidgets('โปรแกรม เลือกได้หลายอัน (toggle)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final programs = <AppointmentProgram>{};
    final ctrl = TextEditingController();
    addTearDown(ctrl.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (c, setState) => Step3Details(
              doctor: Doctor.mock[4],
              selectedTime: '09:30',
              format: AppointmentFormat.online,
              onFormatChanged: (_) {},
              programs: programs,
              onProgramToggled: (p) => setState(() {
                programs.contains(p) ? programs.remove(p) : programs.add(p);
              }),
              detailsController: ctrl,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // เลือกทั้งสอง
    await tester.tap(find.text('พบแพทย์,ปรึกษา'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('นัดหมายติดตาม'));
    await tester.pumpAndSettle();
    expect(programs, {
      AppointmentProgram.consult,
      AppointmentProgram.followUp,
    });

    // แตะซ้ำ = เอาออก (toggle)
    await tester.tap(find.text('พบแพทย์,ปรึกษา'));
    await tester.pumpAndSettle();
    expect(programs, {AppointmentProgram.followUp});
  });
}
