import 'package:floor/floor.dart';

import 'package:xlist/database/entity/index.dart';

@dao
abstract class PasswordManagerDao {
  @Query(
    'SELECT * FROM password_manager WHERE server_id = :serverId AND path = :path',
  )
  Future<List<PasswordManagerEntity>?> findPasswordManagerByPath(
      int serverId, String path);

  @Query('DELETE FROM password_manager WHERE server_id = :serverId')
  Future<void> deletePasswordManagerByServerId(int serverId);

  @insert
  Future<int> insertPasswordManager(PasswordManagerEntity entity);

  @update
  Future<int> updatePasswordManager(PasswordManagerEntity entity);
}
