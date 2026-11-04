import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

class GetAllAttendance {
  final AttendanceRepository repository;

  GetAllAttendance(this.repository);

  List<AttendanceModel> call() {
    return repository.getAllAttendance();
  }
}
