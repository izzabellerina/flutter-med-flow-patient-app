import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Stepper แนวนอนแบบเลข 1-2-3 + เส้นเชื่อม
/// - step ที่ทำแล้ว (index < current) = วงทึบ teal + ✓
/// - step ปัจจุบัน (index == current) = วงทึบ teal + เลข + วงแหวนรอบ
/// - step ที่ยังไม่ถึง (index > current) = วงขาวขอบเทา + เลขเทา
class StepIndicator extends StatelessWidget {
  /// ป้ายกำกับแต่ละ step (เช่น ['เลือกแพทย์', 'เลือกเวลา', 'รายละเอียด'])
  final List<String> labels;

  /// step ปัจจุบัน (เริ่มที่ 0)
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.labels,
    required this.currentStep,
  });

  static const double _circle = 36;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── แถววงกลม + เส้นเชื่อม ────────────────────────────────
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0)
                Expanded(
                  // เส้นก่อนโหนด i เป็น teal เมื่อผ่านโหนดนั้นมาแล้ว
                  child: _Connector(active: currentStep >= i),
                ),
              _Node(index: i, currentStep: currentStep),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // ── แถวป้ายกำกับ (จัดชิดใต้วงกลมริม-กลาง-ริม) ─────────────
        Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Text(
                  labels[i],
                  textAlign: i == 0
                      ? TextAlign.start
                      : (i == labels.length - 1
                          ? TextAlign.end
                          : TextAlign.center),
                  style: AppTheme.generalText(
                    13,
                    fonWeight:
                        i == currentStep ? FontWeight.w700 : FontWeight.w400,
                    color: i <= currentStep
                        ? AppTheme.primaryThemeApp
                        : AppTheme.secondaryText9A,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  final int index;
  final int currentStep;

  const _Node({required this.index, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final done = index < currentStep;
    final current = index == currentStep;
    final reached = index <= currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: StepIndicator._circle,
      height: StepIndicator._circle,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: reached ? AppTheme.primaryThemeApp : AppTheme.whiteColor,
        border: Border.all(
          color: reached ? AppTheme.primaryThemeApp : AppTheme.lineColorD9,
          width: 2,
        ),
        // วงแหวนเน้น step ปัจจุบัน
        boxShadow: current
            ? [
                BoxShadow(
                  color: AppTheme.primaryThemeApp.withValues(alpha: 0.25),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
        child: done
            ? Icon(Icons.check,
                key: const ValueKey('check'),
                size: 20,
                color: AppTheme.whiteColor)
            : Text(
                '${index + 1}',
                key: ValueKey('num${index + 1}'),
                style: AppTheme.generalText(
                  16,
                  fonWeight: FontWeight.w700,
                  color:
                      reached ? AppTheme.whiteColor : AppTheme.secondaryText9A,
                ),
              ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  final bool active;
  const _Connector({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryThemeApp : AppTheme.lineColorD9,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
