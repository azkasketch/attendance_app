import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/permission_model.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocDir.path);
      debugPrint('Hive initialized with path: ${appDocDir.path}');
    } catch (e) {
      await Hive.initFlutter();
      debugPrint('Hive initialized (web fallback)');
    }
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AttendanceModelAdapter());
      debugPrint('AttendanceModelAdapter registered');
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PermissionModelAdapter());
      debugPrint('PermissionModelAdapter registered');
    }
    
    await Hive.openBox(AppConstants.attendanceBox);
    debugPrint('Attendance box opened');
    await Hive.openBox(AppConstants.permissionBox);
    debugPrint('Permission box opened');
  }

  static Box get attendanceBox => Hive.box(AppConstants.attendanceBox);
  static Box get permissionBox => Hive.box(AppConstants.permissionBox);
}
