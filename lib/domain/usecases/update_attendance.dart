import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

class UpdateAttendance {
  final AttendanceRepository repository;

  UpdateAttendance(this.repository);

  Future<void> call(AttendanceModel attendance) {
    return repository.updateAttendance(attendance);
  }
}
