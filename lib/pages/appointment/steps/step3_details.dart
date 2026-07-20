import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/doctor_model.dart';
import '../../../widgets/doctor_info_card.dart';
import '../appointment_ui.dart';

/// Step 3 — สรุปแพทย์/เวลา + เลือกรูปแบบ + โปรแกรม + กรอกรายละเอียด
class Step3Details extends StatelessWidget {
  final Doctor doctor;
  final String selectedTime;

  final AppointmentFormat? format;
  final ValueChanged<AppointmentFormat> onFormatChanged;

  // โปรแกรมเลือกได้หลายอัน (multi-select)
  final Set<AppointmentProgram> programs;
  final ValueChanged<AppointmentProgram> onProgramToggled;

  final TextEditingController detailsController;

  const Step3Details({
    super.key,
    required this.doctor,
    required this.selectedTime,
    required this.format,
    required this.onFormatChanged,
    required this.programs,
    required this.onProgramToggled,
    required this.detailsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DoctorInfoCard(doctor: doctor),
        const SizedBox(height: 16),

        // ── เวลาที่เลือก ────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.access_time, size: 20, color: AppTheme.primaryThemeApp),
            const SizedBox(width: 8),
            Text(
              'เวลา $selectedTime น.',
              style: AppTheme.generalText(
                18,
                fonWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── รูปแบบ ──────────────────────────────────────────────
        const AppointmentSectionTitle('รูปแบบ'),
        const SizedBox(height: 10),
        _pillRow([
          for (final f in AppointmentFormat.values)
            AppointmentChoicePill(
              label: f.label,
              selected: format == f,
              onTap: () => onFormatChanged(f),
            ),
        ]),
        const SizedBox(height: 24),

        // ── โปรแกรม (chip แบบ outline + ติ๊กถูก — ต่างจาก "รูปแบบ") ──
        const AppointmentSectionTitle('โปรแกรม'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final p in AppointmentProgram.values)
              AppointmentChoiceChip(
                label: p.label,
                selected: programs.contains(p),
                onTap: () => onProgramToggled(p),
              ),
          ],
        ),
        const SizedBox(height: 24),

        // ── รายละเอียด ──────────────────────────────────────────
        const AppointmentSectionTitle('รายละเอียด'),
        const SizedBox(height: 10),
        TextField(
          controller: detailsController,
          maxLines: 5,
          minLines: 4,
          style: AppTheme.generalText(16, color: AppTheme.primaryText),
          decoration: InputDecoration(
            hintText: 'ระบุอาการหรือรายละเอียดเพิ่มเติม (ถ้ามี)',
            hintStyle:
                AppTheme.generalText(15, color: AppTheme.secondaryText9A),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  /// 2 pill เรียงแนวนอน กว้างเท่ากัน สูงเท่ากัน
  /// IntrinsicHeight ทำให้ stretch มีความสูงที่ bounded (อยู่ใน vertical scroll ได้)
  Widget _pillRow(List<Widget> pills) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < pills.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: pills[i]),
          ],
        ],
      ),
    );
  }
}
