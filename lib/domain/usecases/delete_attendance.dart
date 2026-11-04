import '../../data/repositories/attendance_repository.dart';

class DeleteAttendance {
  final AttendanceRepository repository;

  DeleteAttendance(this.repository);

  Future<void> call(String id) {
    return repository.deleteAttendance(id);
  }
}
