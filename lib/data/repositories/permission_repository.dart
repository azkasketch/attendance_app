import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/permission_model.dart';
import '../../core/database/hive_service.dart';

class PermissionRepository {
  final Box _box = HiveService.permissionBox;

  Future<void> addPermission(PermissionModel permission) async {
    await _box.put(permission.id, permission);
    debugPrint('Permission added: ${permission.id}');
  }

  List<PermissionModel> getAllPermissions() {
    final list = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    debugPrint('Permission list loaded: ${list.length} items');
    return list.cast<PermissionModel>();
  }
}
