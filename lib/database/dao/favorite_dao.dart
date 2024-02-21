import 'package:floor/floor.dart';

import 'package:xlist/database/entity/index.dart';

@dao
abstract class FavoriteDao {
  @Query(
    'SELECT * FROM favorite WHERE server_id = :serverId ORDER BY updated_at DESC LIMIT :limit OFFSET :offset',
  )
  Future<List<FavoriteEntity>> findFavoriteByServerId(
      int serverId, int limit, int offset);

  @Query(
    'SELECT * FROM favorite WHERE server_id = :serverId AND path = :path AND name = :name',
  )
  Future<FavoriteEntity?> findFavoriteByServerIdAndPath(
      int serverId, String path, String name);

  @Query('DELETE FROM favorite WHERE id = :id')
  Future<void> deleteFavoriteById(int id);

  @Query('DELETE FROM favorite WHERE server_id = :serverId')
  Future<void> deleteFavoriteByServerId(int serverId);

  @insert
  Future<int> insertFavorite(FavoriteEntity favorite);

  @update
  Future<int> updateFavorite(FavoriteEntity favorite);
}
