import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/doctor_model.dart';
import '../../../widgets/doctor_info_card.dart';

/// Step 2 — สรุปแพทย์ที่เลือก + เลือกช่วงเวลา (radio) ช่อง "ไม่ว่าง" กดไม่ได้
class Step2SelectTime extends StatelessWidget {
  final Doctor doctor;
  final List<TimeSlot> slots;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;

  const Step2SelectTime({
    super.key,
    required this.doctor,
    required this.slots,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DoctorInfoCard(doctor: doctor),
        const SizedBox(height: 20),
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: AppTheme.lineColorD9),
          _SlotRow(
            slot: slots[i],
            selected: selectedTime == slots[i].time,
            onTap: slots[i].available
                ? () => onTimeSelected(slots[i].time)
                : null,
          ),
        ],
      ],
    );
  }
}

class _SlotRow extends StatelessWidget {
  final TimeSlot slot;
  final bool selected;
  final VoidCallback? onTap;

  const _SlotRow({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = slot.available;
    final timeColor =
        available ? AppTheme.primaryText : AppTheme.secondaryText9A;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            _RadioDot(selected: selected, available: available),
            const SizedBox(width: 14),
            Text(
              slot.time,
              style: AppTheme.generalText(
                18,
                fonWeight: FontWeight.w600,
                color: timeColor,
              ),
            ),
            const Spacer(),
            Text(
              available ? 'ว่าง' : 'ไม่ว่าง',
              style: AppTheme.generalText(
                16,
                color: available
                    ? AppTheme.successColor
                    : AppTheme.secondaryText9A,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// วงกลม radio ที่วาดเอง — เลือกได้ = teal ทึบมีจุด, ว่างแต่ยังไม่เลือก = ขอบเทา,
/// ไม่ว่าง = สีจางเต็มวง (กดไม่ได้)
class _RadioDot extends StatelessWidget {
  final bool selected;
  final bool available;

  const _RadioDot({required this.selected, required this.available});

  @override
  Widget build(BuildContext context) {
    if (!available) {
      // ช่องไม่ว่าง — วงเทาทึบจาง
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.lineColorD9,
          border: Border.all(color: AppTheme.secondaryText9A, width: 2),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppTheme.primaryThemeApp : Colors.transparent,
        border: Border.all(
          color: selected ? AppTheme.primaryThemeApp : AppTheme.secondaryText62,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.whiteColor,
              ),
            )
          : null,
    );
  }
}
