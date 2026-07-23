import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';

/// สถานะวิดีโอคอล (mock) — ยังไม่ต่อ WebRTC จริง
enum CallState { connecting, live, ended }

/// ตัวคุมสถานะวิดีโอคอล (mock) — แชร์ระหว่างมุมมองในการ์ดกับมุมมองเต็มจอ
/// เพื่อให้สถานะ (กำลังต่อ/live, ไมค์, กล้อง) ตรงกันทั้งสองมุมมอง
class TelemedCallController extends ChangeNotifier {
  CallState _state;
  bool micOn = true;
  bool camOn = true;
  Timer? _timer;

  TelemedCallController({bool active = true})
      : _state = active ? CallState.connecting : CallState.ended {
    if (active) _beginConnecting();
  }

  CallState get state => _state;

  void _beginConnecting() {
    _timer?.cancel();
    _state = CallState.connecting;
    notifyListeners();
    // จำลองการเชื่อมต่อ ~1.6s แล้วเข้าสาย
    _timer = Timer(const Duration(milliseconds: 1600), () {
      _state = CallState.live;
      notifyListeners();
    });
  }

  void startCall() => _beginConnecting();

  void endCall() {
    _timer?.cancel();
    _state = CallState.ended;
    notifyListeners();
  }

  void toggleMic() {
    micOn = !micOn;
    notifyListeners();
  }

  void toggleCam() {
    camOn = !camOn;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// กล่องวิดีโอคอล (mock UI) — โชว์เฉพาะหน้า "เข้าห้องตรวจ"
/// [startActive] = true → เริ่ม connecting อัตโนมัติ แล้วสลับเป็น live
/// มีปุ่มขยายเต็มจอ (รองรับทั้งแนวตั้ง/แนวนอน) และปุ่ม ไมค์/กล้อง/วางสาย (mock)
class TelemedVideoPanel extends StatefulWidget {
  final bool startActive;

  const TelemedVideoPanel({super.key, this.startActive = true});

  @override
  State<TelemedVideoPanel> createState() => _TelemedVideoPanelState();
}

class _TelemedVideoPanelState extends State<TelemedVideoPanel> {
  late final TelemedCallController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TelemedCallController(active: widget.startActive);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => TelemedVideoFullscreenPage(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => TelemedVideoStage(
            controller: _controller,
            fullscreen: false,
            onToggleFullscreen: _openFullscreen,
          ),
        ),
      ),
    );
  }
}

/// หน้าวิดีโอคอลเต็มจอ — ใช้ controller ตัวเดียวกับการ์ด (สถานะไม่หลุด)
/// รองรับหมุนได้ทั้งแนวตั้ง/แนวนอน (แอปไม่ได้ล็อก orientation)
class TelemedVideoFullscreenPage extends StatefulWidget {
  final TelemedCallController controller;

  const TelemedVideoFullscreenPage({super.key, required this.controller});

  @override
  State<TelemedVideoFullscreenPage> createState() =>
      _TelemedVideoFullscreenPageState();
}

class _TelemedVideoFullscreenPageState
    extends State<TelemedVideoFullscreenPage> {
  @override
  void initState() {
    super.initState();
    // โหมดเต็มจอจริง — ซ่อน status/nav bar (ปัดขอบเพื่อเรียกกลับ)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // คืน system UI ปกติเมื่อออกจากเต็มจอ
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (_, __) => TelemedVideoStage(
          controller: widget.controller,
          fullscreen: true,
          onToggleFullscreen: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

/// พื้นผิววิดีโอ (ใช้ซ้ำทั้งในการ์ดและเต็มจอ) — วาดตามสถานะใน [controller]
class TelemedVideoStage extends StatelessWidget {
  final TelemedCallController controller;
  final bool fullscreen;
  final VoidCallback onToggleFullscreen;

  const TelemedVideoStage({
    super.key,
    required this.controller,
    required this.fullscreen,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      color: const Color(0xFF1B1F24),
      child: SafeArea(
        // เต็มจอ → กัน notch/ปุ่มระบบ; ในการ์ด → ไม่ต้อง inset
        top: fullscreen,
        bottom: fullscreen,
        left: fullscreen,
        right: fullscreen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildStage(),
            // แถบควบคุมด้านล่าง
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildControls(),
            ),
            // ป้ายสถานะมุมบนซ้าย
            Positioned(top: 12, left: 12, child: _StatusChip(state: controller.state)),
            // ปุ่มขยาย/ย่อเต็มจอ มุมบนขวา
            // เต็มจอ → แสดงเสมอ (ปุ่มออก), ในการ์ด → เฉพาะตอนเริ่มคอลแล้ว
            if (fullscreen || controller.state != CallState.ended)
              Positioned(
                top: 8,
                right: 8,
                child: _iconButton(
                  icon: fullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  onTap: onToggleFullscreen,
                ),
              ),
          ],
        ),
      ),
    );
    return content;
  }

  Widget _buildStage() {
    switch (controller.state) {
      case CallState.connecting:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.white70),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'กำลังเชื่อมต่อวิดีโอ...',
                style: AppTheme.generalText(15, color: Colors.white70),
              ),
            ],
          ),
        );
      case CallState.live:
        // จำลองภาพคู่สนทนา + ภาพตัวเองมุมขวาล่าง
        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    child: const Icon(Icons.person,
                        color: Colors.white70, size: 44),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'อยู่ระหว่างวิดีโอคอล',
                    style: AppTheme.generalText(14, color: Colors.white60),
                  ),
                ],
              ),
            ),
            // ภาพตัวเอง (self view) จำลอง
            Positioned(
              right: 12,
              bottom: 74,
              child: Container(
                width: 74,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C333B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(
                  controller.camOn ? Icons.person : Icons.videocam_off,
                  color: Colors.white38,
                  size: 30,
                ),
              ),
            ),
          ],
        );
      case CallState.ended:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_outlined,
                  size: 46, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                'ยังไม่ได้เริ่มวิดีโอคอล',
                style: AppTheme.generalText(15, color: Colors.white70),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: controller.startCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryThemeApp,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.videocam_rounded,
                    size: 18, color: Colors.white),
                label: Text(
                  'เริ่มวิดีโอคอล',
                  style: AppTheme.generalText(
                    14,
                    fonWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildControls() {
    // แสดงแถบปุ่มเฉพาะตอนกำลังคอล/เชื่อมต่อ
    if (controller.state == CallState.ended) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ctrlButton(
            icon: controller.micOn ? Icons.mic : Icons.mic_off,
            active: controller.micOn,
            onTap: controller.toggleMic,
          ),
          const SizedBox(width: 12),
          _ctrlButton(
            icon: controller.camOn ? Icons.videocam : Icons.videocam_off,
            active: controller.camOn,
            onTap: controller.toggleCam,
          ),
          const SizedBox(width: 12),
          _ctrlButton(
            icon: Icons.call_end,
            active: false,
            danger: true,
            onTap: controller.endCall,
          ),
        ],
      ),
    );
  }

  Widget _ctrlButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final Color bg = danger
        ? AppTheme.errorColor
        : (active ? Colors.white : Colors.white.withValues(alpha: 0.22));
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon,
              size: 22,
              color: danger
                  ? Colors.white
                  : (active ? AppTheme.primaryText : Colors.white)),
        ),
      ),
    );
  }

  /// ปุ่มกลมโปร่งแสง (ใช้กับปุ่มเต็มจอ)
  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: Colors.white),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final CallState state;
  const _StatusChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (state) {
      CallState.connecting => (const Color(0xFFE0870B), 'กำลังเชื่อมต่อ'),
      CallState.live => (const Color(0xFF22A45D), 'LIVE'),
      CallState.ended => (AppTheme.secondaryText9A, 'ออฟไลน์'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.generalText(
              12,
              fonWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
