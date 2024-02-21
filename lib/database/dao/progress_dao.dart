import 'package:floor/floor.dart';

import 'package:xlist/database/entity/index.dart';

@dao
abstract class ProgressDao {
  @Query(
    'SELECT * FROM progress WHERE server_id = :serverId AND path = :path AND name = :name',
  )
  Future<ProgressEntity?> findProgressByServerIdAndPath(
      int serverId, String path, String name);

  @Query('DELETE FROM progress WHERE id = :id')
  Future<void> deleteProgressById(int id);

  @Query('DELETE FROM progress WHERE server_id = :serverId')
  Future<void> deleteProgressByServerId(int serverId);

  @insert
  Future<int> insertProgress(ProgressEntity progress);

  @update
  Future<int> updateProgress(ProgressEntity progress);
}
