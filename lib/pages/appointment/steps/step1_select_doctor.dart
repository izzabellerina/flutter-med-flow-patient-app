import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/doctor_model.dart';
import '../../../widgets/department_selector.dart';
import '../../../widgets/doctor_info_card.dart';
import '../../../widgets/month_calendar_picker.dart';
import '../appointment_ui.dart';

/// Step 1 — เลือกวันที่ (ปฏิทินฝังในหน้า) + เลือกแผนก (dropdown) + เลือกแพทย์ (การ์ด)
class Step1SelectDoctor extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateChanged;

  final Department? selectedDepartment;
  final ValueChanged<Department?> onDepartmentChanged;

  final Doctor? selectedDoctor;
  final ValueChanged<Doctor> onDoctorSelected;

  const Step1SelectDoctor({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
    required this.selectedDoctor,
    required this.onDoctorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final doctors = selectedDepartment == null
        ? <Doctor>[]
        : Doctor.byDepartment(selectedDepartment!.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── เลือกวันที่ ─────────────────────────────────────────
        const AppointmentSectionTitle('เลือกวันที่'),
        const SizedBox(height: 10),
        AppointmentCardBox(
          padding: EdgeInsets.zero,
          tinted: true, // พื้น gradient teal อ่อน เหมือนการ์ด "นัดหมายที่จะถึง"
          child: MonthCalendarPicker(
            selectedDate: selectedDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onDateChanged: onDateChanged,
          ),
        ),
        const SizedBox(height: 24),

        // ── เลือกแผนก ───────────────────────────────────────────
        const AppointmentSectionTitle('เลือกแผนก'),
        const SizedBox(height: 10),
        DepartmentSelector(
          departments: Department.mock,
          selected: selectedDepartment,
          onChanged: onDepartmentChanged,
        ),
        const SizedBox(height: 24),

        // ── เลือกแพทย์ ──────────────────────────────────────────
        const AppointmentSectionTitle('เลือกแพทย์'),
        const SizedBox(height: 10),
        if (selectedDepartment == null)
          _hint('กรุณาเลือกแผนกก่อน')
        else if (doctors.isEmpty)
          _hint('ยังไม่มีแพทย์ในแผนกนี้')
        else
          for (var i = 0; i < doctors.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            DoctorInfoCard(
              doctor: doctors[i],
              selected: selectedDoctor?.id == doctors[i].id,
              onTap: () => onDoctorSelected(doctors[i]),
            ),
          ],
      ],
    );
  }

  Widget _hint(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lineColorD9),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
        ),
      );
}
