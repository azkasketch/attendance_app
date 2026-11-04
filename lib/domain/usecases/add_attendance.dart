import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

class AddAttendance {
  final AttendanceRepository repository;

  AddAttendance(this.repository);

  Future<void> call(AttendanceModel attendance) {
    return repository.addAttendance(attendance);
  }
}
