/// นัดหมาย — โครงข้อมูลสำหรับ UI (ตอนนี้ป้อนด้วย mock data)
class AppointmentModel {
  final String doctorName;
  final String specialty;
  final String date; // เช่น "18 พ.ย. 2568 (จันทร์)"
  final String time; // เช่น "18:00 - 18:30 น."
  final String? avatarUrl;

  const AppointmentModel({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    this.avatarUrl,
  });

  /// ข้อมูลตัวอย่างสำหรับหน้าแรก — แทนที่ด้วย API เมื่อฝั่ง patient พร้อม
  static const List<AppointmentModel> mockUpcoming = [
    AppointmentModel(
      doctorName: 'นพ. อาลี ข่าน',
      specialty: 'อายุรกรรมหัวใจ',
      date: '18 พ.ย. 2568 (จันทร์)',
      time: '18:00 - 18:30 น.',
    ),
    AppointmentModel(
      doctorName: 'พญ. สุดา ใจดี',
      specialty: 'ผิวหนัง',
      date: '25 พ.ย. 2568 (อังคาร)',
      time: '10:00 - 10:30 น.',
    ),
    AppointmentModel(
      doctorName: 'นพ. ธนา รักษ์ดี',
      specialty: 'ทันตกรรม',
      date: '2 ธ.ค. 2568 (อังคาร)',
      time: '09:30 - 10:00 น.',
    ),
  ];
}
