import 'package:flutter/foundation.dart';
import '../../data/models/permission_model.dart';
import '../../data/repositories/permission_repository.dart';
import '../../domain/usecases/add_permission.dart';
import '../../domain/usecases/get_all_permissions.dart';

class PermissionProvider extends ChangeNotifier {
  final AddPermission _addPermission;
  final GetAllPermissions _getAllPermissions;

  List<PermissionModel> _permissionList = [];
  bool _isLoading = false;
  String? _errorMessage;

  PermissionProvider({
    required PermissionRepository repository,
  })  : _addPermission = AddPermission(repository),
        _getAllPermissions = GetAllPermissions(repository) {
    loadPermissions();
  }

  List<PermissionModel> get permissionList => _permissionList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPermissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _permissionList = _getAllPermissions();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPermission(PermissionModel permission) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addPermission(permission);
      await loadPermissions();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
