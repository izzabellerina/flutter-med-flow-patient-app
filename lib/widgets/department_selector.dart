import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/doctor_model.dart';

/// ตัวเลือก "แผนก" — dropdown ที่กางเมนูใต้ช่อง (anchored overlay)
/// UI: การ์ดมุมโค้ง + เงานุ่ม + ไอคอนประจำแผนก + ไฮไลต์ตัวที่เลือก + animation กางลง
class DepartmentSelector extends StatefulWidget {
  final List<Department> departments;
  final Department? selected;
  final ValueChanged<Department> onChanged;

  const DepartmentSelector({
    super.key,
    required this.departments,
    required this.selected,
    required this.onChanged,
  });

  /// ไอคอนประจำแผนก (ตาม id)
  static IconData iconFor(String id) => switch (id) {
        'internal' => Icons.medical_services_outlined,
        'cardio' => Icons.monitor_heart_outlined,
        'skin' => Icons.spa_outlined,
        'dental' => Icons.masks_outlined,
        'ortho' => Icons.accessibility_new_rounded,
        _ => Icons.local_hospital_outlined,
      };

  @override
  State<DepartmentSelector> createState() => _DepartmentSelectorState();
}

class _DepartmentSelectorState extends State<DepartmentSelector>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  // เก็บ OverlayState ไว้ตั้งแต่ตอน context ยัง active (กัน "deactivated ancestor"
  // ถ้า _open ถูกเรียกช่วง widget กำลังถูก teardown)
  OverlayState? _overlayState;
  // สร้างใน initState (ไม่ใช่ late-init ตอนใช้ครั้งแรก) — กัน AnimationController(vsync: this)
  // ถูกสร้างตอน dispose (ถ้าไม่เคยเปิด dropdown) ซึ่ง createTicker จะ lookup TickerMode
  // บน context ที่ deactivate แล้ว → "deactivated ancestor"
  late final AnimationController _anim;

  bool get _isOpen => _entry != null;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _overlayState = Overlay.of(context);
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _anim.dispose();
    super.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    final overlay = _overlayState;
    final box = context.findRenderObject() as RenderBox?;
    if (overlay == null || box == null || !overlay.mounted) return;
    final size = box.size;
    final topLeft = box.localToGlobal(Offset.zero);
    // อ่าน MediaQuery จาก context ของ Overlay (root) — ไม่ใช่ context ช่อง
    // เพราะหน้าห่อ SafeArea ทำให้ viewPadding.bottom ถูก zero ใน context ลูก
    final mq = MediaQuery.of(overlay.context);

    const gap = 6.0;
    final spaceBelow =
        mq.size.height - (topLeft.dy + size.height) - mq.viewPadding.bottom - gap - 8;
    final spaceAbove = topLeft.dy - mq.viewPadding.top - gap - 8;

    // ถ้าที่ด้านล่างน้อย และด้านบนกว้างกว่า → กางขึ้น
    final openUpward = spaceBelow < 220 && spaceAbove > spaceBelow;
    final maxHeight =
        (openUpward ? spaceAbove : spaceBelow).clamp(140.0, 360.0);

    _entry = OverlayEntry(
      builder: (_) => _DropdownOverlay(
        link: _link,
        fieldSize: size,
        animation: _anim,
        maxHeight: maxHeight,
        openUpward: openUpward,
        departments: widget.departments,
        selectedId: widget.selected?.id,
        onPick: (dep) {
          widget.onChanged(dep);
          _close();
        },
        onDismiss: _close,
      ),
    );
    overlay.insert(_entry!);
    setState(() {});
    _anim.forward();
  }

  void _close() {
    final entry = _entry;
    if (entry == null) return;
    // ปิดสถานะทันที (chevron/ขอบช่องกลับเป็นปิด) แล้วค่อยลบ overlay เมื่อ animation จบ
    _entry = null;
    // whenCompleteOrCancel ทำงานทั้งกรณี animation จบปกติและถูกยกเลิก (เช่น dispose)
    // → ไม่มี await ค้าง/ไม่มี unhandled error ตอน teardown
    _anim.reverse().whenCompleteOrCancel(() {
      entry.remove();
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.selected != null;
    return CompositedTransformTarget(
      link: _link,
      child: Material(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isOpen ? AppTheme.primaryThemeApp : AppTheme.lineColorD9,
                width: _isOpen ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (hasValue) ...[
                  _IconBadge(icon: DepartmentSelector.iconFor(widget.selected!.id)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    hasValue ? widget.selected!.name : 'เลือกแผนก',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.generalText(
                      16,
                      fonWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue
                          ? AppTheme.primaryText
                          : AppTheme.secondaryText9A,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: _isOpen
                          ? AppTheme.primaryThemeApp
                          : AppTheme.secondaryText62),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// เนื้อหา overlay ของ dropdown (กางใต้ช่อง)
class _DropdownOverlay extends StatelessWidget {
  final LayerLink link;
  final Size fieldSize;
  final Animation<double> animation;
  final double maxHeight;
  final bool openUpward;
  final List<Department> departments;
  final String? selectedId;
  final ValueChanged<Department> onPick;
  final VoidCallback onDismiss;

  const _DropdownOverlay({
    required this.link,
    required this.fieldSize,
    required this.animation,
    required this.maxHeight,
    required this.openUpward,
    required this.departments,
    required this.selectedId,
    required this.onPick,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return Stack(
      children: [
        // แตะนอกพื้นที่เพื่อปิด — translucent เพื่อปล่อยให้ scroll/แตะทะลุไปหน้าหลังได้
        // (การเลื่อนหน้าจะถูกจับโดย scroll listener แล้วปิด dropdown เอง)
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          // กางลง = เกาะขอบล่างช่อง / กางขึ้น = เกาะขอบบนช่อง
          targetAnchor:
              openUpward ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor:
              openUpward ? Alignment.bottomLeft : Alignment.topLeft,
          offset: Offset(0, openUpward ? -6 : 6),
          child: Align(
            alignment: openUpward ? Alignment.bottomLeft : Alignment.topLeft,
            child: SizedBox(
              width: fieldSize.width,
              child: FadeTransition(
                opacity: curved,
                child: SizeTransition(
                  sizeFactor: curved,
                  // โตออกจากขอบที่ติดกับช่อง
                  axisAlignment: openUpward ? 1 : -1,
                  child: _menuCard(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuCard() {
    return Material(
      color: AppTheme.whiteColor,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemCount: departments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (_, i) {
            final dep = departments[i];
            final isSelected = selectedId == dep.id;
            return _DeptTile(
              dep: dep,
              isSelected: isSelected,
              onTap: () => onPick(dep),
            );
          },
        ),
      ),
    );
  }
}

class _DeptTile extends StatelessWidget {
  final Department dep;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeptTile({
    required this.dep,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryThemeApp.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _IconBadge(icon: DepartmentSelector.iconFor(dep.id)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dep.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.generalText(
                    16,
                    fonWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryThemeApp
                        : AppTheme.primaryText,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle,
                    color: AppTheme.primaryThemeApp, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.primaryThemeApp.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: AppTheme.primaryThemeApp),
    );
  }
}
