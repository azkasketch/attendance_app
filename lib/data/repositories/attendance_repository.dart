import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/attendance_model.dart';
import '../../core/database/hive_service.dart';

class AttendanceRepository {
  final Box _box = HiveService.attendanceBox;

  Future<void> addAttendance(AttendanceModel attendance) async {
    await _box.put(attendance.id, attendance);
    debugPrint('Attendance added: ${attendance.id}');
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    await _box.put(attendance.id, attendance);
  }

  Future<void> deleteAttendance(String id) async {
    await _box.delete(id);
  }

  List<AttendanceModel> getAllAttendance() {
    final list = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    debugPrint('Attendance list loaded: ${list.length} items');
    return list.cast<AttendanceModel>();
  }
}
