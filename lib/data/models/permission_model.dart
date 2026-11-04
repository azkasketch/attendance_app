import 'package:hive/hive.dart';

part 'permission_model.g.dart';

@HiveType(typeId: 1)
class PermissionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String fromDate;

  @HiveField(4)
  final String toDate;

  @HiveField(5)
  final DateTime createdAt;

  PermissionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.fromDate,
    required this.toDate,
    required this.createdAt,
  });
}
