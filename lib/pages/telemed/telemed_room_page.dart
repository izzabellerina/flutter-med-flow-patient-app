import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/appointment_model.dart';
import '../../widgets/telemed_room_header.dart';
import '../../widgets/telemed_tab_bar.dart';
import '../../widgets/telemed_video_panel.dart';

/// หน้า "ห้อง Telemed" — ใช้ทั้ง 2 กรณี:
/// - [startVideoCall] = true  → ปุ่ม "เข้าห้องตรวจ": มีกล่องวิดีโอ + เริ่มคอลทันที (รูปที่ 2)
/// - [startVideoCall] = false → ปุ่ม "ดูรายละเอียด": ไม่มีกล่องวิดีโอ (รูปที่ 1)
/// Layout รองรับ responsive: แนวตั้ง = คอลัมน์เดียว, แนวนอน = 2 คอลัมน์ (รูปที่ 3)
class TelemedRoomPage extends StatefulWidget {
  final AppointmentModel appointment;
  final bool startVideoCall;

  const TelemedRoomPage({
    super.key,
    required this.appointment,
    required this.startVideoCall,
  });

  @override
  State<TelemedRoomPage> createState() => _TelemedRoomPageState();
}

class _TelemedRoomPageState extends State<TelemedRoomPage> {
  // ── แท็ปหลัก ──
  static const List<String> _mainTabs = <String>[
    'ตรวจ/วินิจฉัย',
    'คัดกรอง',
    'SOAP Note',
    'การสั่งการรักษา',
    'นัดหมายครั้งถัดไป',
    'แชท',
  ];

  // ── แท็ปย่อยของแท็ปหลัก (index → รายการแท็ปย่อย). ตอนนี้มีเฉพาะ "ตรวจ/วินิจฉัย" ──
  static const Map<int, List<String>> _subTabs = <int, List<String>>{
    0: <String>['อาการสำคัญ', 'ตรวจร่างกาย', 'วินิจฉัย ICD-1'],
  };

  int _mainIndex = 0;
  int _subIndex = 0;

  List<String>? get _currentSubTabs => _subTabs[_mainIndex];

  void _onMainSelected(int i) {
    if (i == _mainIndex) return;
    setState(() {
      _mainIndex = i;
      _subIndex = 0; // เปลี่ยนแท็ปหลัก → รีเซ็ตแท็ปย่อย
    });
  }

  @override
  Widget build(BuildContext context) {
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
          widget.appointment.doctorName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.generalText(
            18,
            fonWeight: FontWeight.w700,
            color: AppTheme.primaryText,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // แนวนอน → แยกซ้าย(หัว+วิดีโอ) / ขวา(แท็ป+เนื้อหา)
            final isLandscape =
                constraints.maxWidth > constraints.maxHeight &&
                    constraints.maxWidth >= 600;
            return isLandscape ? _buildWideLayout() : _buildNarrowLayout();
          },
        ),
      ),
    );
  }

  // ── แนวตั้ง: คอลัมน์เดียว, ทั้งหน้า scroll ได้ ──
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TelemedRoomHeader(appointment: widget.appointment),
          if (widget.startVideoCall) ...[
            const SizedBox(height: 14),
            TelemedVideoPanel(startActive: widget.startVideoCall),
          ],
          const SizedBox(height: 16),
          _buildTabSection(),
        ],
      ),
    );
  }

  // ── แนวนอน: ซ้าย(หัว+วิดีโอ) | ขวา(แท็ป+เนื้อหา) ตามรูปที่ 3 ──
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // คอลัมน์ซ้าย
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TelemedRoomHeader(appointment: widget.appointment),
                if (widget.startVideoCall) ...[
                  const SizedBox(height: 14),
                  TelemedVideoPanel(startActive: widget.startVideoCall),
                ],
              ],
            ),
          ),
        ),
        // คอลัมน์ขวา
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
            child: _buildTabSection(fillContent: true),
          ),
        ),
      ],
    );
  }

  /// แท็ปหลัก + แท็ปย่อย + เนื้อหา (placeholder)
  /// [fillContent] = true (แนวนอน) → เนื้อหา Expanded เต็มความสูง + scroll ในตัว
  /// (แนวตั้ง) → เนื้อหาความสูงตามเนื้อหา (ทั้งหน้า scroll จากภายนอก)
  Widget _buildTabSection({bool fillContent = false}) {
    final subs = _currentSubTabs;
    final content = _buildTabContent();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: fillContent ? MainAxisSize.max : MainAxisSize.min,
      children: [
        TelemedTabBar(
          tabs: _mainTabs,
          selectedIndex: _mainIndex,
          onSelected: _onMainSelected,
          primary: true,
        ),
        if (subs != null) ...[
          const SizedBox(height: 10),
          TelemedTabBar(
            tabs: subs,
            selectedIndex: _subIndex,
            onSelected: (i) => setState(() => _subIndex = i),
            primary: false,
          ),
        ],
        const SizedBox(height: 16),
        if (fillContent)
          Expanded(
            child: SingleChildScrollView(child: content),
          )
        else
          content,
      ],
    );
  }

  /// เนื้อหาแต่ละแท็ป — รอบนี้เป็น placeholder ("กำลังพัฒนา")
  Widget _buildTabContent() {
    final subs = _currentSubTabs;
    final title = (subs != null) ? subs[_subIndex] : _mainTabs[_mainIndex];

    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconForTab(_mainIndex),
              size: 44,
              color: AppTheme.secondaryText9A,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.generalText(
                18,
                fonWeight: FontWeight.w700,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'กำลังพัฒนา',
              style: AppTheme.generalText(15, color: AppTheme.secondaryText62),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForTab(int i) {
    switch (i) {
      case 0:
        return Icons.assignment_outlined; // ตรวจ/วินิจฉัย
      case 1:
        return Icons.fact_check_outlined; // คัดกรอง
      case 2:
        return Icons.note_alt_outlined; // SOAP Note
      case 3:
        return Icons.medication_outlined; // การสั่งการรักษา
      case 4:
        return Icons.event_available_outlined; // นัดหมายครั้งถัดไป
      case 5:
        return Icons.chat_bubble_outline; // แชท
      default:
        return Icons.info_outline;
    }
  }
}
