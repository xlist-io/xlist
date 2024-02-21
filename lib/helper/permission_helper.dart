import 'package:xlist/models/index.dart';
import 'package:xlist/constants/index.dart';

class PermissionHelper {
  static bool isAdmin(UserModel user) => user.role == UserRole.ADMIN;
  static bool isGeneral(UserModel user) => user.role == UserRole.GENERAL;
  static bool isGuest(UserModel user) => user.role == UserRole.GUEST;

  /// 是否有权限
  /// [user] 用户
  /// [permission] 权限
  static bool can(UserModel user, int permission) {
    return PermissionHelper.isAdmin(user) ||
        ((user.permission! >> permission) & 1) == 1;
  }

  static bool canSeeHides(UserModel user) => PermissionHelper.can(user, 0);
  static bool canAccessWithoutPassword(UserModel user) =>
      PermissionHelper.can(user, 1);
  static bool canOfflineDownload(UserModel user) =>
      PermissionHelper.can(user, 2);
  static bool canWrite(UserModel user) => PermissionHelper.can(user, 3);
  static bool canRename(UserModel user) => PermissionHelper.can(user, 4);
  static bool canMove(UserModel user) => PermissionHelper.can(user, 5);
  static bool canCopy(UserModel user) => PermissionHelper.can(user, 6);
  static bool canDelete(UserModel user) => PermissionHelper.can(user, 7);
  static bool canWebdavRead(UserModel user) => PermissionHelper.can(user, 8);
  static bool canWebdavManage(UserModel user) => PermissionHelper.can(user, 9);
}
