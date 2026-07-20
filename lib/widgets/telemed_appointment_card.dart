import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/appointment_model.dart';

/// การ์ดนัด Telemed — โทนขาวสะอาด + แถบสีแบรนด์ (teal) ด้านซ้าย
/// สถานะ "พร้อมเข้าห้อง" → การ์ดมี outline + glow เต้นเป็นจังหวะ (pulse)
/// เพื่อให้ผู้ใช้รับรู้ว่าหมอพร้อมวิดีโอคอลแล้ว + ปุ่ม "เข้าห้องตรวจ"
class TelemedAppointmentCard extends StatefulWidget {
  final AppointmentModel appointment;
  final VoidCallback onJoin;
  final VoidCallback onViewDetail;

  const TelemedAppointmentCard({
    super.key,
    required this.appointment,
    required this.onJoin,
    required this.onViewDetail,
  });

  @override
  State<TelemedAppointmentCard> createState() => _TelemedAppointmentCardState();
}

class _TelemedAppointmentCardState extends State<TelemedAppointmentCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  bool get _isReady =>
      widget.appointment.status == AppointmentStatus.ready;

  @override
  void initState() {
    super.initState();
    if (_isReady) _startPulse();
  }

  @override
  void didUpdateWidget(TelemedAppointmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // สถานะเปลี่ยนไป/มา "พร้อมเข้าห้อง" → เปิด/ปิด pulse ให้ตรง
    if (_isReady && _pulse == null) {
      _startPulse();
    } else if (!_isReady && _pulse != null) {
      _pulse!.dispose();
      _pulse = null;
    }
  }

  void _startPulse() {
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.primaryThemeApp; // สีแบรนด์ teal

    if (!_isReady) return _card(accent, glow: 0);

    // สถานะพร้อม → หายใจเข้า-ออกด้วยค่า 0..1 ขับ outline + glow
    return AnimatedBuilder(
      animation: _pulse!,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulse!.value);
        return _card(accent, glow: t);
      },
    );
  }

  /// [glow] 0 = ไม่มี pulse (สถานะปกติ), >0 = ความเข้มของ outline/แสงเรือง
  Widget _card(Color accent, {required double glow}) {
    final canJoin = _isReady;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: glow > 0
            ? Border.all(
                color: accent.withValues(alpha: 0.35 + 0.45 * glow),
                width: 1.5 + 0.8 * glow,
              )
            : null,
        boxShadow: [
          if (glow > 0)
            // แสงเรือง teal เต้นตามจังหวะ → ดึงสายตา
            BoxShadow(
              color: accent.withValues(alpha: 0.18 + 0.28 * glow),
              blurRadius: 10 + 16 * glow,
              spreadRadius: 1 + 2 * glow,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // แถบสีแบรนด์ด้านซ้าย — สื่อว่าเป็นนัด Telemed
            Container(width: 5, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // แถวหมอ + สถานะ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: accent.withValues(alpha: 0.12),
                          child: Icon(Icons.person, color: accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                widget.appointment.doctorName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.generalText(
                                  18,
                                  fonWeight: FontWeight.w700,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.appointment.specialty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.generalText(
                                  15,
                                  color: AppTheme.secondaryText62,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: widget.appointment.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // เวลา
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.appointment.time,
                            style: AppTheme.generalText(
                              16,
                              color: AppTheme.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ปุ่ม — พร้อมเข้าห้อง → "เข้าห้องตรวจ" เท่านั้น, สถานะอื่น → "ดูรายละเอียด"
                    canJoin
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: widget.onJoin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                minimumSize: const Size(0, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(
                                Icons.videocam_rounded,
                                size: 18,
                                color: AppTheme.whiteColor,
                              ),
                              label: Text(
                                'เข้าห้องตรวจ',
                                style: AppTheme.generalText(
                                  15,
                                  fonWeight: FontWeight.w600,
                                  color: AppTheme.whiteColor,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: widget.onViewDetail,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                                side: BorderSide(color: AppTheme.lineColorD9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'ดูรายละเอียด',
                                style: AppTheme.generalText(
                                  15,
                                  fonWeight: FontWeight.w600,
                                  color: AppTheme.secondaryText62,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ป้ายสถานะนัด — สี + ไอคอนตามสถานะ
class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (status) {
      AppointmentStatus.ready => (const Color(0xFF22A45D), Icons.check_circle),
      AppointmentStatus.waiting => (
          const Color(0xFFE0870B),
          Icons.schedule_rounded,
        ),
      AppointmentStatus.done => (
          AppTheme.secondaryText9A,
          Icons.done_all_rounded,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppTheme.generalText(
              12,
              fonWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
