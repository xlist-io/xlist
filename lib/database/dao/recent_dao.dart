import 'package:floor/floor.dart';

import 'package:xlist/database/entity/index.dart';

@dao
abstract class RecentDao {
  @Query(
    'SELECT * FROM recent WHERE server_id = :serverId ORDER BY updated_at DESC LIMIT :limit OFFSET :offset',
  )
  Future<List<RecentEntity>> findRecentByServerId(
      int serverId, int limit, int offset);

  @Query(
    'SELECT * FROM recent WHERE server_id = :serverId AND path = :path AND name = :name',
  )
  Future<RecentEntity?> findRecentByServerIdAndPath(
      int serverId, String path, String name);

  @Query('DELETE FROM recent WHERE id = :id')
  Future<void> deleteRecentById(int id);

  @Query('DELETE FROM recent WHERE server_id = :serverId')
  Future<void> deleteRecentByServerId(int serverId);

  @insert
  Future<int> insertRecent(RecentEntity recent);

  @update
  Future<int> updateRecent(RecentEntity recent);
}
