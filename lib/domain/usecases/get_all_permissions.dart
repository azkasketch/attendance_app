import '../../data/models/permission_model.dart';
import '../../data/repositories/permission_repository.dart';

class GetAllPermissions {
  final PermissionRepository repository;

  GetAllPermissions(this.repository);

  List<PermissionModel> call() {
    return repository.getAllPermissions();
  }
}
