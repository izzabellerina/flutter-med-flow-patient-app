import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/appointment_model.dart';
import '../../widgets/month_calendar_picker.dart';
import '../../widgets/telemed_appointment_card.dart';

/// หน้า Telemed — รายการนัดหมาย Telemed กรองตามวันที่ (default = วันนี้)
class TelemedPage extends StatefulWidget {
  const TelemedPage({super.key});

  @override
  State<TelemedPage> createState() => _TelemedPageState();
}

class _TelemedPageState extends State<TelemedPage> {
  late DateTime _selectedDate; // default = วันนี้
  late final DateTime _firstDate;
  late final DateTime _lastDate;

  // นัด Telemed ทั้งหมด (mock) — จริง ๆ ควรดึงจาก API ตามช่วงวันที่
  late final List<AppointmentModel> _all;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _firstDate = today;
    _lastDate = DateTime(today.year + 100, today.month, today.day); // ดูล่วงหน้า 100 ปี
    _selectedDate = today;
    _all = AppointmentModel.mockTelemed;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // นัดของวันที่เลือก — "พร้อมเข้าห้อง" ขึ้นก่อนเสมอ จากนั้นเรียงตามเวลา
  List<AppointmentModel> get _forSelectedDay {
    final list = _all
        .where((a) => _sameDay(a.dateTime, _selectedDate))
        .toList()
      ..sort((a, b) {
        final aReady = a.status == AppointmentStatus.ready;
        final bReady = b.status == AppointmentStatus.ready;
        if (aReady != bReady) return aReady ? -1 : 1;
        return a.dateTime.compareTo(b.dateTime);
      });
    return list;
  }

  void _openCalendar() {
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: AppTheme.primaryThemeApp),
                    const SizedBox(width: 8),
                    Text(
                      'เลือกวันที่',
                      style: AppTheme.generalText(
                        20,
                        fonWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              MonthCalendarPicker(
                selectedDate: _selectedDate,
                firstDate: _firstDate,
                lastDate: _lastDate,
                onDateChanged: (d) {
                  Navigator.of(sheetContext).pop();
                  setState(() => _selectedDate = d);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _forSelectedDay;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        surfaceTintColor: AppTheme.whiteColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.primaryText,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Telemed',
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
            // ── แถบวันที่ (แตะเพื่อเปิดปฏิทิน) ค้างบนสุด ──
            _DateBar(date: _selectedDate, onTap: _openCalendar),
            Divider(height: 1, color: AppTheme.lineColorD9),

            // ── รายการนัดของวันที่เลือก ──
            Expanded(
              child: items.isEmpty
                  ? _EmptyState(date: _selectedDate)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => TelemedAppointmentCard(
                        appointment: items[i],
                        onJoin: () =>
                            _comingSoon('เข้าห้องตรวจ — ${items[i].doctorName}'),
                        onViewDetail: () => _comingSoon(
                            'รายละเอียด — ${items[i].doctorName}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — กำลังพัฒนา')),
    );
  }
}

/// แถบวันที่ด้านบน — แสดงวันที่เลือก (ไทย พ.ศ.) แตะทั้งแถบเพื่อเปิดปฏิทิน
class _DateBar extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateBar({required this.date, required this.onTap});

  static const List<String> _thaiWeekdaysFull = <String>[
    'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์',
  ];
  static const List<String> _thaiMonthsFull = <String>[
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  @override
  Widget build(BuildContext context) {
    final wd = _thaiWeekdaysFull[date.weekday - 1];
    final text =
        'วัน$wd ${date.day} ${_thaiMonthsFull[date.month - 1]} ${date.year + 543}';
    return Material(
      color: AppTheme.whiteColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 22, color: AppTheme.primaryThemeApp),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: AppTheme.generalText(
                    17,
                    fonWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.secondaryText62),
            ],
          ),
        ),
      ),
    );
  }
}

/// สถานะว่างเมื่อไม่มีนัด Telemed ในวันที่เลือก
class _EmptyState extends StatelessWidget {
  final DateTime date;
  const _EmptyState({required this.date});

  static const List<String> _thaiMonthsFull = <String>[
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  @override
  Widget build(BuildContext context) {
    final thai =
        '${date.day} ${_thaiMonthsFull[date.month - 1]} ${date.year + 543}';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_camera_front_outlined,
                size: 64, color: AppTheme.secondaryText9A),
            const SizedBox(height: 16),
            Text(
              'ไม่มีนัด Telemed',
              style: AppTheme.generalText(
                18,
                fonWeight: FontWeight.w700,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'วันที่ $thai',
              textAlign: TextAlign.center,
              style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
            ),
          ],
        ),
      ),
    );
  }
}
