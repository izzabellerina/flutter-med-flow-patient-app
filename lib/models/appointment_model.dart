/// รูปแบบการเข้าพบ — ใช้แสดง badge บนการ์ดนัดหมาย
enum AppointmentType {
  telemed('Telemed'),
  onsite('มาที่ รพ.');

  final String label;
  const AppointmentType(this.label);
}

/// สถานะนัด Telemed — คุมป้ายสถานะ + การเปิดใช้ปุ่ม "เข้าห้องตรวจ"
enum AppointmentStatus {
  waiting('รอถึงเวลา'), // ยังไม่ถึงเวลา — เข้าห้องยังไม่ได้
  ready('พร้อมเข้าห้อง'), // ถึงเวลาแล้ว — กดเข้าห้องได้
  done('เสร็จสิ้น'); // ตรวจเสร็จแล้ว

  final String label;
  const AppointmentStatus(this.label);
}

/// นัดหมาย — โครงข้อมูลสำหรับ UI (ตอนนี้ป้อนด้วย mock data)
class AppointmentModel {
  final String doctorName;
  final String specialty;
  final String date; // เช่น "18 พ.ย. 2568 (จันทร์)"
  final String time; // เช่น "18:00 - 18:30 น."
  final AppointmentType type;
  final AppointmentStatus status;
  final String? avatarUrl;

  /// ชื่อคนไข้ — แสดงในหัวห้อง Telemed ("คนไข้ : ...")
  final String? patientName;

  /// วัน-เวลาจริงของนัด — ใช้กรองตามวันที่ (หน้า Telemed)
  /// เก็บแยกจาก [date]/[time] ที่เป็น string สำหรับแสดงผล
  final DateTime dateTime;

  const AppointmentModel({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.dateTime,
    this.type = AppointmentType.onsite,
    this.status = AppointmentStatus.waiting,
    this.avatarUrl,
    this.patientName,
  });

  /// ข้อมูลตัวอย่างสำหรับหน้าแรก — แทนที่ด้วย API เมื่อฝั่ง patient พร้อม
  static final List<AppointmentModel> mockUpcoming = [
    AppointmentModel(
      doctorName: 'นพ. อาลี ข่าน',
      specialty: 'อายุรกรรมหัวใจ',
      date: '18 พ.ย. 2568 (จันทร์)',
      time: '18:00 - 18:30 น.',
      dateTime: DateTime(2025, 11, 18, 18, 0),
      type: AppointmentType.telemed,
    ),
    AppointmentModel(
      doctorName: 'พญ. สุดา ใจดี',
      specialty: 'ผิวหนัง',
      date: '25 พ.ย. 2568 (อังคาร)',
      time: '10:00 - 10:30 น.',
      dateTime: DateTime(2025, 11, 25, 10, 0),
      type: AppointmentType.onsite,
    ),
    AppointmentModel(
      doctorName: 'นพ. ธนา รักษ์ดี',
      specialty: 'ทันตกรรม',
      date: '2 ธ.ค. 2568 (อังคาร)',
      time: '09:30 - 10:00 น.',
      dateTime: DateTime(2025, 12, 2, 9, 30),
      type: AppointmentType.telemed,
    ),
  ];

  /// นัด Telemed ตัวอย่าง — ผูกกับวันปัจจุบัน (วันนี้ + วันใกล้เคียง)
  /// เพื่อให้หน้า Telemed ที่ default = วันนี้ มีข้อมูลให้เห็นทันที
  /// แทนที่ด้วย API (ดึงตามช่วงวันที่) เมื่อฝั่ง patient พร้อม
  static List<AppointmentModel> get mockTelemed {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int addDays, int h, int m) =>
        DateTime(today.year, today.month, today.day + addDays, h, m);

    return [
      // ── วันนี้ ──
      AppointmentModel(
        doctorName: 'นพ. อาลี ข่าน',
        specialty: 'อายุรกรรมหัวใจ',
        date: _thaiFullDate(at(0, 0, 0)),
        time: '14:00 - 14:30 น.',
        dateTime: at(0, 14, 0),
        type: AppointmentType.telemed,
        status: AppointmentStatus.ready,
        patientName: 'สมศรี ใจดี',
      ),
      AppointmentModel(
        doctorName: 'พญ. สุดา ใจดี',
        specialty: 'ผิวหนัง',
        date: _thaiFullDate(at(0, 0, 0)),
        time: '16:30 - 17:00 น.',
        dateTime: at(0, 16, 30),
        type: AppointmentType.telemed,
        status: AppointmentStatus.waiting,
        patientName: 'ประสงค์ มั่นคง',
      ),
      AppointmentModel(
        doctorName: 'นพ. วีระ สุขใจ',
        specialty: 'อายุรกรรมทั่วไป',
        date: _thaiFullDate(at(0, 0, 0)),
        time: '09:00 - 09:30 น.',
        dateTime: at(0, 9, 0),
        type: AppointmentType.telemed,
        status: AppointmentStatus.done,
        patientName: 'วิภา สุขสันต์',
      ),
      // ── พรุ่งนี้ ──
      AppointmentModel(
        doctorName: 'พญ. มาลี ศรีสุข',
        specialty: 'จิตเวช',
        date: _thaiFullDate(at(1, 0, 0)),
        time: '10:00 - 10:30 น.',
        dateTime: at(1, 10, 0),
        type: AppointmentType.telemed,
        status: AppointmentStatus.waiting,
        patientName: 'ธีรพงศ์ ใจงาม',
      ),
      // ── อีก 3 วัน ──
      AppointmentModel(
        doctorName: 'นพ. ธนา รักษ์ดี',
        specialty: 'โภชนาการ',
        date: _thaiFullDate(at(3, 0, 0)),
        time: '13:00 - 13:30 น.',
        dateTime: at(3, 13, 0),
        type: AppointmentType.telemed,
        status: AppointmentStatus.waiting,
        patientName: 'กัญญา พรหมมา',
      ),
    ];
  }

  static const List<String> _thaiMonthsShort = <String>[
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];
  static const List<String> _thaiWeekdays = <String>[
    'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์',
  ];

  // เช่น "20 ก.ค. 2569 (จันทร์)" — พ.ศ.
  static String _thaiFullDate(DateTime d) {
    final wd = _thaiWeekdays[d.weekday - 1];
    return '${d.day} ${_thaiMonthsShort[d.month - 1]} ${d.year + 543} ($wd)';
  }
}
