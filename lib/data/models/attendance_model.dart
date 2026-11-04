import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 0)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String datetime;

  @HiveField(5)
  final double? latitude;

  @HiveField(6)
  final double? longitude;

  @HiveField(7)
  final DateTime createdAt;

  AttendanceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.datetime,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });
}
