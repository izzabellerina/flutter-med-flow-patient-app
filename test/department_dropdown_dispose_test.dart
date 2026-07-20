import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_flow_patient/app/theme.dart';
import 'package:med_flow_patient/models/doctor_model.dart';
import 'package:med_flow_patient/widgets/department_selector.dart';

void main() {
  Widget host(GlobalKey<NavigatorState> navKey, void Function(Department) onCh) {
    Department? sel;
    return MaterialApp(
      navigatorKey: navKey,
      theme: AppTheme.theme,
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).push(MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 200, 20, 20),
                      child: StatefulBuilder(
                        builder: (c, setState) => DepartmentSelector(
                          departments: Department.mock,
                          selected: sel,
                          onChanged: (d) => setState(() {
                            sel = d;
                            onCh(d);
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openOnPage(WidgetTester tester,
      GlobalKey<NavigatorState> navKey) async {
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DepartmentSelector));
  }

  testWidgets('dispose โดยไม่เคยเปิด dropdown — ไม่ error (late _anim)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      home: Scaffold(
        body: DepartmentSelector(
          departments: Department.mock,
          selected: null,
          onChanged: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    // ถอด widget ออกโดยไม่เปิด dropdown → dispose ต้องไม่ lazy-init _anim จน lookup ล้ม
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('pop ขณะ dropdown เปิดเต็ม — ไม่ error', (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(host(navKey, (_) {}));
    await tester.pumpAndSettle();
    await openOnPage(tester, navKey);
    await tester.pumpAndSettle();
    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('pop ระหว่าง animation เปิด — ไม่ error', (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(host(navKey, (_) {}));
    await tester.pumpAndSettle();
    await openOnPage(tester, navKey);
    await tester.pump(const Duration(milliseconds: 60)); // forward ยังไม่จบ
    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('pop ระหว่าง animation ปิด (เลือกแผนก) — ไม่ error', (tester) async {
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(host(navKey, (_) {}));
    await tester.pumpAndSettle();
    await openOnPage(tester, navKey);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ทันตกรรม')); // เริ่ม animation ปิด
    await tester.pump(const Duration(milliseconds: 60));
    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
