import 'package:floor/floor.dart';

import 'package:xlist/database/entity/index.dart';

@dao
abstract class ServerDao {
  @Query('SELECT * FROM server')
  Future<List<ServerEntity>> findAllServer();

  @Query('SELECT * FROM server WHERE id = :id')
  Future<ServerEntity?> findServerById(int id);

  @Query('DELETE FROM server WHERE id = :id')
  Future<void> deleteServerById(int id);

  @insert
  Future<int> insertServer(ServerEntity server);

  @update
  Future<int> updateServer(ServerEntity server);
}
