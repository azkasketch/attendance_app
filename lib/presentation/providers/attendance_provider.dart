import 'package:flutter/foundation.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../domain/usecases/add_attendance.dart';
import '../../domain/usecases/get_all_attendance.dart';
import '../../domain/usecases/update_attendance.dart';
import '../../domain/usecases/delete_attendance.dart';

class AttendanceProvider extends ChangeNotifier {
  final GetAllAttendance _getAllAttendance;
  final AddAttendance _addAttendance;
  final UpdateAttendance _updateAttendance;
  final DeleteAttendance _deleteAttendance;

  List<AttendanceModel> _attendanceList = [];
  bool _isLoading = false;
  String? _errorMessage;

  AttendanceProvider({
    required AttendanceRepository repository,
  })  : _getAllAttendance = GetAllAttendance(repository),
        _addAttendance = AddAttendance(repository),
        _updateAttendance = UpdateAttendance(repository),
        _deleteAttendance = DeleteAttendance(repository) {
    loadAttendance();
  }

  List<AttendanceModel> get attendanceList => _attendanceList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAttendance() async {
    _isLoading = true;
    notifyListeners();

    try {
      _attendanceList = _getAllAttendance();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAttendance(AttendanceModel attendance) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addAttendance(attendance);
      await loadAttendance();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _updateAttendance(attendance);
      await loadAttendance();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAttendance(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _deleteAttendance(id);
      await loadAttendance();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
