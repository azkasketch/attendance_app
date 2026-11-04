import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/permission_repository.dart';
import 'presentation/providers/attendance_provider.dart';
import 'presentation/providers/permission_provider.dart';
import 'presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AttendanceProvider(repository: AttendanceRepository())),
        ChangeNotifierProvider(create: (_) => PermissionProvider(repository: PermissionRepository())),
      ],
      child: const AttendanceApp(),
    ),
  );
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
