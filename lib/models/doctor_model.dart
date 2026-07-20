// ข้อมูลสำหรับ flow "นัดหมายใหม่" — ตอนนี้ป้อนด้วย mock data
// (แทนที่ด้วย API เมื่อฝั่ง patient พร้อม)

/// แผนก
class Department {
  final String id;
  final String name;
  const Department({required this.id, required this.name});

  /// mock แผนก
  static const List<Department> mock = [
    Department(id: 'internal', name: 'อายุรกรรม'),
    Department(id: 'cardio', name: 'อายุรกรรมหัวใจ'),
    Department(id: 'skin', name: 'ผิวหนัง'),
    Department(id: 'dental', name: 'ทันตกรรม'),
    Department(id: 'ortho', name: 'กระดูกและข้อ'),
  ];
}

/// แพทย์
class Doctor {
  final String id;
  final String name;
  final String departmentId;
  final String departmentName;

  /// ช่วงเวลาออกตรวจ เช่น "15:00 - 19:00"
  final String workStart; // "15:00"
  final String workEnd; // "19:00"

  const Doctor({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.departmentName,
    required this.workStart,
    required this.workEnd,
  });

  String get workRange => '$workStart - $workEnd';

  /// mock แพทย์ (หลายคนต่อแผนก)
  static const List<Doctor> mock = [
    Doctor(
      id: 'd1',
      name: 'นพ. สมชสาย ใจดี',
      departmentId: 'internal',
      departmentName: 'อายุรกรรม',
      workStart: '15:00',
      workEnd: '19:00',
    ),
    Doctor(
      id: 'd2',
      name: 'พญ. สุดา ใจดี',
      departmentId: 'internal',
      departmentName: 'อายุรกรรม',
      workStart: '09:00',
      workEnd: '12:00',
    ),
    Doctor(
      id: 'd3',
      name: 'นพ. อาลี ข่าน',
      departmentId: 'cardio',
      departmentName: 'อายุรกรรมหัวใจ',
      workStart: '13:00',
      workEnd: '16:00',
    ),
    Doctor(
      id: 'd4',
      name: 'พญ. มณี รักษา',
      departmentId: 'skin',
      departmentName: 'ผิวหนัง',
      workStart: '10:00',
      workEnd: '14:00',
    ),
    Doctor(
      id: 'd5',
      name: 'นพ. ธนา รักษ์ดี',
      departmentId: 'dental',
      departmentName: 'ทันตกรรม',
      workStart: '09:30',
      workEnd: '12:30',
    ),
    Doctor(
      id: 'd6',
      name: 'นพ. ปกรณ์ มั่นคง',
      departmentId: 'ortho',
      departmentName: 'กระดูกและข้อ',
      workStart: '13:30',
      workEnd: '17:30',
    ),
  ];

  /// แพทย์ในแผนกที่เลือก
  static List<Doctor> byDepartment(String departmentId) =>
      mock.where((d) => d.departmentId == departmentId).toList();
}

/// ช่องเวลานัด (ทุก 15 นาที)
class TimeSlot {
  final String time; // "15:00"
  final bool available;
  const TimeSlot({required this.time, required this.available});

  /// สร้างช่องเวลาทุก 15 นาที ตั้งแต่ workStart ถึง workEnd (ไม่รวมปลาย)
  /// mock: ทุกช่องที่ index % 3 == 2 เป็น "ไม่ว่าง" (deterministic ไม่สุ่ม)
  static List<TimeSlot> forDoctor(Doctor doctor) {
    final start = _toMinutes(doctor.workStart);
    final end = _toMinutes(doctor.workEnd);
    final slots = <TimeSlot>[];
    var i = 0;
    for (var m = start; m < end; m += 15) {
      slots.add(TimeSlot(time: _fromMinutes(m), available: i % 3 != 2));
      i++;
    }
    return slots;
  }

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String _fromMinutes(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// รูปแบบการนัด
enum AppointmentFormat {
  online('Telemed'),
  onsite('มาที่ รพ เอง');

  final String label;
  const AppointmentFormat(this.label);
}

/// โปรแกรมการนัด
enum AppointmentProgram {
  consult('พบแพทย์,ปรึกษา'),
  followUp('นัดหมายติดตาม');

  final String label;
  const AppointmentProgram(this.label);
}
