import 'package:floor/floor.dart';

import 'package:xlist/database/entity/index.dart';

@dao
abstract class DownloadDao {
  @Query('SELECT * FROM download')
  Future<List<DownloadEntity>> findAllDownload();

  @Query('SELECT * FROM download WHERE id = :id')
  Future<DownloadEntity?> findDownloadById(int id);

  @Query('SELECT * FROM download WHERE server_id = :serverId')
  Future<DownloadEntity?> findDownloadByServerId(int serverId);

  @Query(
    'SELECT * FROM download WHERE server_id = :serverId AND path = :path AND name = :name',
  )
  Future<DownloadEntity?> findDownloadByServerIdAndPath(
      int serverId, String path, String name);

  @Query('DELETE FROM download WHERE id = :id')
  Future<void> deleteDownloadById(int id);

  @Query('DELETE FROM download WHERE server_id = :serverId')
  Future<void> deleteDownloadByServerId(int serverId);

  @insert
  Future<int> insertDownload(DownloadEntity download);

  @update
  Future<int> updateDownload(DownloadEntity download);
}
