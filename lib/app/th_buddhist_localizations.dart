import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// MaterialLocalizations ภาษาไทยที่แสดง "ปี" เป็น **พุทธศักราช** (พ.ศ. = ค.ศ. + 543)
///
/// ต่อยอดจาก [MaterialLocalizationTh] (คลาส public ที่ flutter_localizations export)
/// แล้ว override เฉพาะเมธอดจัดรูปแบบปี — ส่วนอื่น (ปุ่ม/ป้าย/ชื่อเดือน-วัน) คงของไทยเดิม
/// - หัวปฏิทิน (`formatMonthYear`): "กรกฎาคม พ.ศ. 2569"
/// - ตารางเลือกปี (`formatYear`): "2569"
class MaterialLocalizationThBe extends MaterialLocalizationTh {
  const MaterialLocalizationThBe({
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  static const List<String> _thaiMonths = <String>[
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  int _buddhistYear(int gregorianYear) => gregorianYear + 543;

  @override
  String formatYear(DateTime date) => '${_buddhistYear(date.year)}';

  @override
  String formatMonthYear(DateTime date) =>
      '${_thaiMonths[date.month - 1]} พ.ศ. ${_buddhistYear(date.year)}';
}

/// Delegate ที่จ่าย [MaterialLocalizationThBe] สำหรับ locale ไทย
class _ThaiBuddhistMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _ThaiBuddhistMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'th';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // ให้ delegate มาตรฐานโหลด intl date data ให้ก่อน (คืน SynchronousFuture →
    // ทำงานแบบ sync ไม่มีเฟรมกระพริบ) แล้วค่อยสร้างตัวแบบ พ.ศ.
    return GlobalMaterialLocalizations.delegate.load(locale).then((_) {
      return MaterialLocalizationThBe(
        fullYearFormat: intl.DateFormat.y('th'),
        compactDateFormat: intl.DateFormat.yMd('th'),
        shortDateFormat: intl.DateFormat.yMMMd('th'),
        mediumDateFormat: intl.DateFormat.MMMEd('th'),
        longDateFormat: intl.DateFormat.yMMMMEEEEd('th'),
        yearMonthFormat: intl.DateFormat.yMMMM('th'),
        shortMonthDayFormat: intl.DateFormat.MMMd('th'),
        decimalFormat: intl.NumberFormat.decimalPattern('th'),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', 'th'),
      );
    });
  }

  @override
  bool shouldReload(_ThaiBuddhistMaterialLocalizationsDelegate old) => false;
}

/// ใช้แทน [GlobalMaterialLocalizations.delegate] ใน `MaterialApp.localizationsDelegates`
/// เพื่อให้ปฏิทิน/date picker แสดงปีเป็น พ.ศ.
const LocalizationsDelegate<MaterialLocalizations> thaiBuddhistMaterialDelegate =
    _ThaiBuddhistMaterialLocalizationsDelegate();
