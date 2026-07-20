import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/doctor_model.dart';
import '../../widgets/step_indicator.dart';
import 'steps/step1_select_doctor.dart';
import 'steps/step2_select_time.dart';
import 'steps/step3_details.dart';

/// หน้า "นัดหมายใหม่" — flow 3 step (เลือกแพทย์ → เลือกเวลา → รายละเอียด)
class NewAppointmentPage extends StatefulWidget {
  const NewAppointmentPage({super.key});

  @override
  State<NewAppointmentPage> createState() => _NewAppointmentPageState();
}

class _NewAppointmentPageState extends State<NewAppointmentPage> {
  static const _stepLabels = ['เลือกแพทย์', 'เลือกเวลา', 'รายละเอียด'];

  int _step = 0;
  bool _forward = true; // ทิศทางการเปลี่ยน step (ถัดไป = true, ย้อน = false)

  // ── ฟอร์ม state ──────────────────────────────────────────────
  late DateTime _selectedDate;
  late final DateTime _firstDate;
  late final DateTime _lastDate;

  Department? _department;
  Doctor? _doctor;
  String? _time;
  AppointmentFormat? _format;
  final Set<AppointmentProgram> _programs = {}; // เลือกได้หลายอัน
  final TextEditingController _detailsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _firstDate = DateTime(now.year, now.month, now.day);
    // จองล่วงหน้าได้ 100 ปี
    _lastDate = DateTime(now.year + 100, now.month, now.day);
    _selectedDate = _firstDate;
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  // ── validation ต่อ step ──────────────────────────────────────
  bool get _canProceed {
    switch (_step) {
      case 0:
        return _department != null && _doctor != null;
      case 1:
        return _time != null;
      case 2:
        return _format != null && _programs.isNotEmpty;
      default:
        return false;
    }
  }

  bool get _isLastStep => _step == _stepLabels.length - 1;

  // ── การเปลี่ยนค่า ────────────────────────────────────────────
  void _onDepartmentChanged(Department? dep) {
    setState(() {
      _department = dep;
      _doctor = null; // เปลี่ยนแผนก → ล้างแพทย์ที่เคยเลือก
      _time = null;
    });
  }

  void _onDoctorSelected(Doctor doctor) {
    setState(() {
      _doctor = doctor;
      _time = null; // เปลี่ยนแพทย์ → ช่วงเวลาเปลี่ยน
    });
  }

  // วันที่แบบไทย พ.ศ. เช่น "17 กรกฎาคม 2569"
  static const List<String> _thaiMonths = <String>[
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];
  String get _thaiDate =>
      '${_selectedDate.day} ${_thaiMonths[_selectedDate.month - 1]} ${_selectedDate.year + 543}';

  // ── ปุ่มล่าง ──────────────────────────────────────────────────
  void _onPrimary() {
    if (!_canProceed) return;
    if (_isLastStep) {
      _showSummary(); // step สุดท้าย → เปิด modal สรุปก่อนยืนยันจริง
    } else {
      setState(() {
        _forward = true;
        _step++;
      });
    }
  }

  // ปุ่ม "ก่อนหน้า" — ย้อนไป step ก่อนหน้า (เรียกเมื่อ _step > 0 เท่านั้น)
  void _goPreviousStep() {
    if (_step == 0) return;
    setState(() {
      _forward = false;
      _step--;
    });
  }

  // เปิด modal สรุปข้อมูลทุก step ก่อนยืนยัน
  void _showSummary() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.whiteColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.lineColorD9,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.event_available_outlined,
                        color: AppTheme.primaryThemeApp),
                    const SizedBox(width: 8),
                    Text(
                      'สรุปการนัดหมาย',
                      style: AppTheme.generalText(
                        20,
                        fonWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppTheme.lineColorD9),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryRow(Icons.person_outline, 'แพทย์',
                          '${_doctor!.name}\nแผนก${_doctor!.departmentName}'),
                      _summaryRow(
                          Icons.calendar_today_outlined, 'วันที่', _thaiDate),
                      _summaryRow(Icons.access_time, 'เวลา', '$_time น.'),
                      _summaryRow(Icons.devices_outlined, 'รูปแบบ',
                          _format?.label ?? '-'),
                      _summaryRow(
                        Icons.medical_services_outlined,
                        'โปรแกรม',
                        _programs.map((p) => p.label).join(' • '),
                      ),
                      _summaryRow(
                        Icons.notes_outlined,
                        'รายละเอียด',
                        _detailsCtrl.text.trim().isEmpty
                            ? '-'
                            : _detailsCtrl.text.trim(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          side: BorderSide(color: AppTheme.lineColorD9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'แก้ไข',
                          style: AppTheme.generalText(
                            16,
                            fonWeight: FontWeight.w600,
                            color: AppTheme.secondaryText62,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(); // ปิด modal สรุป
                          _showSuccess();
                        },
                        child: const Text('ยืนยันการนัดหมาย'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryThemeApp.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryThemeApp),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.generalText(
                      14, color: AppTheme.secondaryText62),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.generalText(
                    16,
                    fonWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle,
                color: AppTheme.successColor, size: 64),
            const SizedBox(height: 12),
            Text(
              'ส่งคำขอนัดหมายแล้ว',
              style: AppTheme.generalText(
                20,
                fonWeight: FontWeight.w700,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_doctor!.name}\n${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year + 543} เวลา $_time น.',
              textAlign: TextAlign.center,
              style:
                  AppTheme.generalText(16, color: AppTheme.secondaryText62),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิด dialog
                Navigator.of(context).pop(); // ปิดหน้านัดหมาย
              },
              child: const Text('เสร็จสิ้น'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.whiteColor,
          surfaceTintColor: AppTheme.whiteColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          // ปุ่ม back = ยกเลิก (ออกจาก flow ทั้งหมด)
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.primaryText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'นัดหมายใหม่',
            style: AppTheme.generalText(
              20,
              fonWeight: FontWeight.w700,
              color: AppTheme.primaryText,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // ── Stepper ค้างบนสุด ───────────────────────────────
              Container(
                color: AppTheme.whiteColor,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: StepIndicator(
                  labels: _stepLabels,
                  currentStep: _step,
                ),
              ),
              Divider(height: 1, color: AppTheme.lineColorD9),

              // ── เนื้อหาแต่ละ step (สไลด์+เฟดตามทิศทางเปลี่ยน step) ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    // ให้เนื้อหาชิดบนระหว่าง transition (ไม่เด้งกลางจอ)
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: Offset(_forward ? 0.10 : -0.10, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStepBody(),
                    ),
                  ),
                ),
              ),

              // ── แถบปุ่มล่าง ─────────────────────────────────────
              _bottomBar(),
            ],
          ),
        ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return Step1SelectDoctor(
          selectedDate: _selectedDate,
          firstDate: _firstDate,
          lastDate: _lastDate,
          onDateChanged: (d) => setState(() => _selectedDate = d),
          selectedDepartment: _department,
          onDepartmentChanged: _onDepartmentChanged,
          selectedDoctor: _doctor,
          onDoctorSelected: _onDoctorSelected,
        );
      case 1:
        return Step2SelectTime(
          doctor: _doctor!,
          slots: TimeSlot.forDoctor(_doctor!),
          selectedTime: _time,
          onTimeSelected: (t) => setState(() => _time = t),
        );
      case 2:
        return Step3Details(
          doctor: _doctor!,
          selectedTime: _time!,
          format: _format,
          onFormatChanged: (f) => setState(() => _format = f),
          programs: _programs,
          onProgramToggled: (p) => setState(() {
            _programs.contains(p) ? _programs.remove(p) : _programs.add(p);
          }),
          detailsController: _detailsCtrl,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _bottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ก่อนหน้า — ย้อนไป step ก่อนหน้า (ปิดใช้งานที่ step แรก)
            Expanded(
              child: OutlinedButton(
                onPressed: _step == 0 ? null : _goPreviousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  side: BorderSide(color: AppTheme.lineColorD9),
                  disabledForegroundColor: AppTheme.secondaryText9A,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ก่อนหน้า',
                  style: AppTheme.generalText(
                    16,
                    fonWeight: FontWeight.w600,
                    color: _step == 0
                        ? AppTheme.secondaryText9A
                        : AppTheme.secondaryText62,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // ถัดไป / ยืนยัน
            Expanded(
              child: ElevatedButton(
                onPressed: _canProceed ? _onPrimary : null,
                child: Text(_isLastStep ? 'ยืนยัน' : 'ถัดไป'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
