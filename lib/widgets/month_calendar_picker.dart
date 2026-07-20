import 'package:flutter/material.dart';

import '../app/theme.dart';

/// โหมดที่แผงปฏิทินกำลังแสดง
enum _Mode { days, months, years }

/// ปฏิทินฝังในหน้า (เลือกวันได้) ที่ทำเอง
/// - เลือก **เดือน / ปี (พ.ศ.)** ผ่าน **แผงตาราง** (แตะหัวเพื่อเปิดแผง) ไม่ใช่ dropdown
/// - วันนอกช่วง [firstDate, lastDate] จะจางและกดไม่ได้
class MonthCalendarPicker extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateChanged;

  const MonthCalendarPicker({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  @override
  State<MonthCalendarPicker> createState() => _MonthCalendarPickerState();
}

class _MonthCalendarPickerState extends State<MonthCalendarPicker> {
  late DateTime _displayed; // เก็บแค่ปี+เดือน
  _Mode _mode = _Mode.days;
  final ScrollController _yearsCtrl = ScrollController();

  static const double _yearItemHeight = 52;
  static const double _panelHeight = 264;

  static const List<String> _thaiMonthsFull = <String>[
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];
  static const List<String> _thaiMonthsShort = <String>[
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];
  static const List<String> _thaiWeekdays = <String>[
    'อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส',
  ];

  @override
  void initState() {
    super.initState();
    _displayed = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  void didUpdateWidget(MonthCalendarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameMonth(widget.selectedDate, oldWidget.selectedDate) &&
        !_sameMonth(widget.selectedDate, _displayed)) {
      _displayed = DateTime(widget.selectedDate.year, widget.selectedDate.month);
    }
  }

  @override
  void dispose() {
    _yearsCtrl.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────
  bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  bool _inRange(DateTime d) =>
      !d.isBefore(_dayOnly(widget.firstDate)) &&
      !d.isAfter(_dayOnly(widget.lastDate));

  int get _daysInDisplayedMonth =>
      DateTime(_displayed.year, _displayed.month + 1, 0).day;
  int get _leadingBlanks =>
      DateTime(_displayed.year, _displayed.month, 1).weekday % 7;

  bool get _canGoPrev {
    final prevMonthEnd = DateTime(_displayed.year, _displayed.month, 0);
    return !prevMonthEnd.isBefore(_dayOnly(widget.firstDate));
  }

  bool get _canGoNext {
    final nextMonthStart = DateTime(_displayed.year, _displayed.month + 1, 1);
    return !nextMonthStart.isAfter(_dayOnly(widget.lastDate));
  }

  void _shiftMonth(int delta) {
    setState(() => _displayed =
        DateTime(_displayed.year, _displayed.month + delta));
  }

  void _setDisplayed(int year, int month) {
    var target = DateTime(year, month);
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    if (target.isBefore(firstMonth)) target = firstMonth;
    if (target.isAfter(lastMonth)) target = lastMonth;
    setState(() {
      _displayed = target;
      _mode = _Mode.days;
    });
  }

  void _toggleMode(_Mode mode) {
    setState(() => _mode = _mode == mode ? _Mode.days : mode);
    if (_mode == _Mode.years) {
      // เลื่อนแผงปีไปยังปีที่แสดงอยู่
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_yearsCtrl.hasClients) return;
        final index = _displayed.year - widget.firstDate.year;
        final row = index ~/ 3;
        final target = row * _yearItemHeight;
        _yearsCtrl.jumpTo(
          target.clamp(0.0, _yearsCtrl.position.maxScrollExtent),
        );
      });
    }
  }

  // ── build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 8),
            switch (_mode) {
              _Mode.days => _daysView(),
              _Mode.months => _monthsPanel(),
              _Mode.years => _yearsPanel(),
            },
          ],
        ),
      ),
    );
  }

  // ── หัว: ◀ [เดือน] [ปี] ▶ ───────────────────────────────────────
  Widget _header() {
    final showArrows = _mode == _Mode.days;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: showArrows
                ? _arrow(Icons.chevron_left,
                    _canGoPrev ? () => _shiftMonth(-1) : null)
                : null,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _headerButton(
                    _thaiMonthsFull[_displayed.month - 1],
                    active: _mode == _Mode.months,
                    onTap: () => _toggleMode(_Mode.months),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _headerButton(
                    'พ.ศ. ${_displayed.year + 543}',
                    active: _mode == _Mode.years,
                    onTap: () => _toggleMode(_Mode.years),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            child: showArrows
                ? _arrow(Icons.chevron_right,
                    _canGoNext ? () => _shiftMonth(1) : null)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _arrow(IconData icon, VoidCallback? onTap) => IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: AppTheme.primaryThemeApp,
        disabledColor: AppTheme.secondaryText9A.withValues(alpha: 0.4),
        splashRadius: 22,
      );

  Widget _headerButton(String label,
      {required bool active, required VoidCallback onTap}) {
    return Material(
      color: active
          ? AppTheme.primaryThemeApp
          : AppTheme.primaryThemeApp.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTheme.generalText(
              15,
              fonWeight: FontWeight.w700,
              color: active ? AppTheme.whiteColor : AppTheme.primaryThemeApp,
            ),
          ),
        ),
      ),
    );
  }

  // ── โหมดวัน ─────────────────────────────────────────────────────
  Widget _daysView() {
    return Column(
      children: [
        Row(
          children: [
            for (final w in _thaiWeekdays)
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: AppTheme.generalText(
                        14, color: AppTheme.secondaryText62),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        _daysGrid(),
      ],
    );
  }

  Widget _daysGrid() {
    final totalDays = _daysInDisplayedMonth;
    final leading = _leadingBlanks;
    final rows = ((leading + totalDays) / 7).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: _dayCell(r * 7 + c - leading + 1, totalDays),
                ),
            ],
          ),
      ],
    );
  }

  Widget _dayCell(int day, int totalDays) {
    if (day < 1 || day > totalDays) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }
    final date = DateTime(_displayed.year, _displayed.month, day);
    final enabled = _inRange(date);
    final selected = _sameDay(date, widget.selectedDate);
    final isToday = _sameDay(date, _today);

    Color textColor;
    if (selected) {
      textColor = AppTheme.whiteColor;
    } else if (!enabled) {
      textColor = AppTheme.secondaryText9A.withValues(alpha: 0.5);
    } else if (isToday) {
      textColor = AppTheme.primaryThemeApp;
    } else {
      textColor = AppTheme.primaryText;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: selected ? AppTheme.primaryThemeApp : Colors.transparent,
          shape: CircleBorder(
            side: (isToday && !selected)
                ? BorderSide(color: AppTheme.primaryThemeApp, width: 1.5)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? () => widget.onDateChanged(date) : null,
            child: Center(
              child: Text(
                '$day',
                style: AppTheme.generalText(
                  16,
                  fonWeight:
                      selected || isToday ? FontWeight.w700 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── แผงเดือน ─────────────────────────────────────────────────────
  Widget _monthsPanel() {
    final year = _displayed.year;
    final startMonth =
        year == widget.firstDate.year ? widget.firstDate.month : 1;
    final endMonth = year == widget.lastDate.year ? widget.lastDate.month : 12;

    return SizedBox(
      height: _panelHeight,
      child: Column(
        children: [
          for (var r = 0; r < 4; r++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < 3; c++)
                    Expanded(
                      child: _panelCell(
                        label: _thaiMonthsShort[r * 3 + c],
                        selected: (r * 3 + c + 1) == _displayed.month,
                        enabled: (r * 3 + c + 1) >= startMonth &&
                            (r * 3 + c + 1) <= endMonth,
                        onTap: () => _setDisplayed(year, r * 3 + c + 1),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── แผงปี ────────────────────────────────────────────────────────
  Widget _yearsPanel() {
    final firstYear = widget.firstDate.year;
    final count = widget.lastDate.year - firstYear + 1;
    return SizedBox(
      height: _panelHeight,
      child: GridView.builder(
        controller: _yearsCtrl,
        padding: const EdgeInsets.symmetric(vertical: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: _yearItemHeight,
        ),
        itemCount: count,
        itemBuilder: (context, i) {
          final year = firstYear + i;
          return _panelCell(
            label: 'พ.ศ. ${year + 543}',
            selected: year == _displayed.year,
            enabled: true,
            onTap: () => _setDisplayed(year, _displayed.month),
          );
        },
      ),
    );
  }

  // ── เซลล์ในแผง (เดือน/ปี) ─────────────────────────────────────────
  Widget _panelCell({
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    Color textColor;
    if (selected) {
      textColor = AppTheme.whiteColor;
    } else if (!enabled) {
      textColor = AppTheme.secondaryText9A.withValues(alpha: 0.5);
    } else {
      textColor = AppTheme.primaryText;
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: selected
            ? AppTheme.primaryThemeApp
            : (enabled
                ? AppTheme.primaryThemeApp.withValues(alpha: 0.06)
                : Colors.transparent),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.generalText(
                15,
                fonWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
