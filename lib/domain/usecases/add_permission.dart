import '../../data/models/permission_model.dart';
import '../../data/repositories/permission_repository.dart';

class AddPermission {
  final PermissionRepository repository;

  AddPermission(this.repository);

  Future<void> call(PermissionModel permission) {
    return repository.addPermission(permission);
  }
}
