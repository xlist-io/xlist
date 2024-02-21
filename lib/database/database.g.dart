// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorXlistDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$XlistDatabaseBuilder databaseBuilder(String name) =>
      _$XlistDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$XlistDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$XlistDatabaseBuilder(null);
}

class _$XlistDatabaseBuilder {
  _$XlistDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$XlistDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$XlistDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<XlistDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$XlistDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$XlistDatabase extends XlistDatabase {
  _$XlistDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ServerDao? _serverDaoInstance;

  RecentDao? _recentDaoInstance;

  DownloadDao? _downloadDaoInstance;

  ProgressDao? _progressDaoInstance;

  FavoriteDao? _favoriteDaoInstance;

  PasswordManagerDao? _passwordManagerDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `server` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `url` TEXT NOT NULL, `type` INTEGER NOT NULL, `username` TEXT NOT NULL, `password` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `recent` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` INTEGER NOT NULL, `path` TEXT NOT NULL, `name` TEXT NOT NULL, `type` INTEGER NOT NULL, `size` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `download` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` INTEGER NOT NULL, `task_id` TEXT NOT NULL, `type` INTEGER NOT NULL, `path` TEXT NOT NULL, `name` TEXT NOT NULL, `size` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `progress` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` INTEGER NOT NULL, `path` TEXT NOT NULL, `name` TEXT NOT NULL, `current_pos` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `favorite` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` INTEGER NOT NULL, `path` TEXT NOT NULL, `name` TEXT NOT NULL, `type` INTEGER NOT NULL, `size` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `password_manager` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` INTEGER NOT NULL, `path` TEXT NOT NULL, `password` TEXT NOT NULL)');
        await database
            .execute('CREATE INDEX `index_server_url` ON `server` (`url`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_recent_server_id_path_name` ON `recent` (`server_id`, `path`, `name`)');
        await database.execute(
            'CREATE INDEX `index_recent_updated_at` ON `recent` (`updated_at`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_download_server_id_path_name` ON `download` (`server_id`, `path`, `name`)');
        await database.execute(
            'CREATE INDEX `index_download_task_id` ON `download` (`task_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_progress_server_id_path_name` ON `progress` (`server_id`, `path`, `name`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_favorite_server_id_path_name` ON `favorite` (`server_id`, `path`, `name`)');
        await database.execute(
            'CREATE INDEX `index_favorite_updated_at` ON `favorite` (`updated_at`)');
        await database.execute(
            'CREATE INDEX `index_password_manager_server_id_path` ON `password_manager` (`server_id`, `path`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ServerDao get serverDao {
    return _serverDaoInstance ??= _$ServerDao(database, changeListener);
  }

  @override
  RecentDao get recentDao {
    return _recentDaoInstance ??= _$RecentDao(database, changeListener);
  }

  @override
  DownloadDao get downloadDao {
    return _downloadDaoInstance ??= _$DownloadDao(database, changeListener);
  }

  @override
  ProgressDao get progressDao {
    return _progressDaoInstance ??= _$ProgressDao(database, changeListener);
  }

  @override
  FavoriteDao get favoriteDao {
    return _favoriteDaoInstance ??= _$FavoriteDao(database, changeListener);
  }

  @override
  PasswordManagerDao get passwordManagerDao {
    return _passwordManagerDaoInstance ??=
        _$PasswordManagerDao(database, changeListener);
  }
}

class _$ServerDao extends ServerDao {
  _$ServerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _serverEntityInsertionAdapter = InsertionAdapter(
            database,
            'server',
            (ServerEntity item) => <String, Object?>{
                  'id': item.id,
                  'url': item.url,
                  'type': item.type,
                  'username': item.username,
                  'password': item.password
                }),
        _serverEntityUpdateAdapter = UpdateAdapter(
            database,
            'server',
            ['id'],
            (ServerEntity item) => <String, Object?>{
                  'id': item.id,
                  'url': item.url,
                  'type': item.type,
                  'username': item.username,
                  'password': item.password
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ServerEntity> _serverEntityInsertionAdapter;

  final UpdateAdapter<ServerEntity> _serverEntityUpdateAdapter;

  @override
  Future<List<ServerEntity>> findAllServer() async {
    return _queryAdapter.queryList('SELECT * FROM server',
        mapper: (Map<String, Object?> row) => ServerEntity(
            id: row['id'] as int?,
            url: row['url'] as String,
            type: row['type'] as int,
            username: row['username'] as String,
            password: row['password'] as String));
  }

  @override
  Future<ServerEntity?> findServerById(int id) async {
    return _queryAdapter.query('SELECT * FROM server WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ServerEntity(
            id: row['id'] as int?,
            url: row['url'] as String,
            type: row['type'] as int,
            username: row['username'] as String,
            password: row['password'] as String),
        arguments: [id]);
  }

  @override
  Future<void> deleteServerById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM server WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<int> insertServer(ServerEntity server) {
    return _serverEntityInsertionAdapter.insertAndReturnId(
        server, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateServer(ServerEntity server) {
    return _serverEntityUpdateAdapter.updateAndReturnChangedRows(
        server, OnConflictStrategy.abort);
  }
}

class _$RecentDao extends RecentDao {
  _$RecentDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recentEntityInsertionAdapter = InsertionAdapter(
            database,
            'recent',
            (RecentEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'path': item.path,
                  'name': item.name,
                  'type': item.type,
                  'size': item.size,
                  'updated_at': item.updatedAt
                }),
        _recentEntityUpdateAdapter = UpdateAdapter(
            database,
            'recent',
            ['id'],
            (RecentEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'path': item.path,
                  'name': item.name,
                  'type': item.type,
                  'size': item.size,
                  'updated_at': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RecentEntity> _recentEntityInsertionAdapter;

  final UpdateAdapter<RecentEntity> _recentEntityUpdateAdapter;

  @override
  Future<List<RecentEntity>> findRecentByServerId(
    int serverId,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM recent WHERE server_id = ?1 ORDER BY updated_at DESC LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => RecentEntity(id: row['id'] as int?, serverId: row['server_id'] as int, path: row['path'] as String, name: row['name'] as String, type: row['type'] as int, size: row['size'] as int, updatedAt: row['updated_at'] as int),
        arguments: [serverId, limit, offset]);
  }

  @override
  Future<RecentEntity?> findRecentByServerIdAndPath(
    int serverId,
    String path,
    String name,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM recent WHERE server_id = ?1 AND path = ?2 AND name = ?3',
        mapper: (Map<String, Object?> row) => RecentEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as int,
            path: row['path'] as String,
            name: row['name'] as String,
            type: row['type'] as int,
            size: row['size'] as int,
            updatedAt: row['updated_at'] as int),
        arguments: [serverId, path, name]);
  }

  @override
  Future<void> deleteRecentById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM recent WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteRecentByServerId(int serverId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM recent WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertRecent(RecentEntity recent) {
    return _recentEntityInsertionAdapter.insertAndReturnId(
        recent, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateRecent(RecentEntity recent) {
    return _recentEntityUpdateAdapter.updateAndReturnChangedRows(
        recent, OnConflictStrategy.abort);
  }
}

class _$DownloadDao extends DownloadDao {
  _$DownloadDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _downloadEntityInsertionAdapter = InsertionAdapter(
            database,
            'download',
            (DownloadEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'task_id': item.taskId,
                  'type': item.type,
                  'path': item.path,
                  'name': item.name,
                  'size': item.size
                }),
        _downloadEntityUpdateAdapter = UpdateAdapter(
            database,
            'download',
            ['id'],
            (DownloadEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'task_id': item.taskId,
                  'type': item.type,
                  'path': item.path,
                  'name': item.name,
                  'size': item.size
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DownloadEntity> _downloadEntityInsertionAdapter;

  final UpdateAdapter<DownloadEntity> _downloadEntityUpdateAdapter;

  @override
  Future<List<DownloadEntity>> findAllDownload() async {
    return _queryAdapter.queryList('SELECT * FROM download',
        mapper: (Map<String, Object?> row) => DownloadEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as int,
            taskId: row['task_id'] as String,
            type: row['type'] as int,
            path: row['path'] as String,
            name: row['name'] as String,
            size: row['size'] as int));
  }

  @override
  Future<DownloadEntity?> findDownloadById(int id) async {
    return _queryAdapter.query('SELECT * FROM download WHERE id = ?1',
        mapper: (Map<String, Object?> row) => DownloadEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as int,
            taskId: row['task_id'] as String,
            type: row['type'] as int,
            path: row['path'] as String,
            name: row['name'] as String,
            size: row['size'] as int),
        arguments: [id]);
  }

  @override
  Future<DownloadEntity?> findDownloadByServerId(int serverId) async {
    return _queryAdapter.query('SELECT * FROM download WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => DownloadEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as int,
            taskId: row['task_id'] as String,
            type: row['type'] as int,
            path: row['path'] as String,
            name: row['name'] as String,
            size: row['size'] as int),
        arguments: [serverId]);
  }

  @override
  Future<DownloadEntity?> findDownloadByServerIdAndPath(
    int serverId,
    String path,
    String name,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM download WHERE server_id = ?1 AND path = ?2 AND name = ?3',
        mapper: (Map<String, Object?> row) => DownloadEntity(id: row['id'] as int?, serverId: row['server_id'] as int, taskId: row['task_id'] as String, type: row['type'] as int, path: row['path'] as String, name: row['name'] as String, size: row['size'] as int),
        arguments: [serverId, path, name]);
  }

  @override
  Future<void> deleteDownloadById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM download WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteDownloadByServerId(int serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM download WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertDownload(DownloadEntity download) {
    return _downloadEntityInsertionAdapter.insertAndReturnId(
        download, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateDownload(DownloadEntity download) {
    return _downloadEntityUpdateAdapter.updateAndReturnChangedRows(
        download, OnConflictStrategy.abort);
  }
}

class _$ProgressDao extends ProgressDao {
  _$ProgressDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _progressEntityInsertionAdapter = InsertionAdapter(
            database,
            'progress',
            (ProgressEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'path': item.path,
                  'name': item.name,
                  'current_pos': item.currentPos
                }),
        _progressEntityUpdateAdapter = UpdateAdapter(
            database,
            'progress',
            ['id'],
            (ProgressEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'path': item.path,
                  'name': item.name,
                  'current_pos': item.currentPos
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ProgressEntity> _progressEntityInsertionAdapter;

  final UpdateAdapter<ProgressEntity> _progressEntityUpdateAdapter;

  @override
  Future<ProgressEntity?> findProgressByServerIdAndPath(
    int serverId,
    String path,
    String name,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM progress WHERE server_id = ?1 AND path = ?2 AND name = ?3',
        mapper: (Map<String, Object?> row) => ProgressEntity(id: row['id'] as int?, serverId: row['server_id'] as int, path: row['path'] as String, name: row['name'] as String, currentPos: row['current_pos'] as int),
        arguments: [serverId, path, name]);
  }

  @override
  Future<void> deleteProgressById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM progress WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteProgressByServerId(int serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM progress WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertProgress(ProgressEntity progress) {
    return _progressEntityInsertionAdapter.insertAndReturnId(
        progress, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateProgress(ProgressEntity progress) {
    return _progressEntityUpdateAdapter.updateAndReturnChangedRows(
        progress, OnConflictStrategy.abort);
  }
}

class _$FavoriteDao extends FavoriteDao {
  _$FavoriteDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _favoriteEntityInsertionAdapter = InsertionAdapter(
            database,
            'favorite',
            (FavoriteEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'path': item.path,
                  'name': item.name,
                  'type': item.type,
                  'size': item.size,
                  'updated_at': item.updatedAt
                }),
        _favoriteEntityUpdateAdapter = UpdateAdapter(
            database,
            'favorite',
            ['id'],
            (FavoriteEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'path': item.path,
                  'name': item.name,
                  'type': item.type,
                  'size': item.size,
                  'updated_at': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FavoriteEntity> _favoriteEntityInsertionAdapter;

  final UpdateAdapter<FavoriteEntity> _favoriteEntityUpdateAdapter;

  @override
  Future<List<FavoriteEntity>> findFavoriteByServerId(
    int serverId,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM favorite WHERE server_id = ?1 ORDER BY updated_at DESC LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => FavoriteEntity(id: row['id'] as int?, serverId: row['server_id'] as int, path: row['path'] as String, name: row['name'] as String, type: row['type'] as int, size: row['size'] as int, updatedAt: row['updated_at'] as int),
        arguments: [serverId, limit, offset]);
  }

  @override
  Future<FavoriteEntity?> findFavoriteByServerIdAndPath(
    int serverId,
    String path,
    String name,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM favorite WHERE server_id = ?1 AND path = ?2 AND name = ?3',
        mapper: (Map<String, Object?> row) => FavoriteEntity(id: row['id'] as int?, serverId: row['server_id'] as int, path: row['path'] as String, name: row['name'] as String, type: row['type'] as int, size: row['size'] as int, updatedAt: row['updated_at'] as int),
        arguments: [serverId, path, name]);
  }

  @override
  Future<void> deleteFavoriteById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM favorite WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteFavoriteByServerId(int serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM favorite WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertFavorite(FavoriteEntity favorite) {
    return _favoriteEntityInsertionAdapter.insertAndReturnId(
        favorite, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateFavorite(FavoriteEntity favorite) {
    return _favoriteEntityUpdateAdapter.updateAndReturnChangedRows(
        favorite, OnConflictStrategy.abort);
  }
}

class _$PasswordManagerDao extends PasswordManagerDao {
  _$PasswordManagerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _passwordManagerEntityInsertionAdapter = InsertionAdapter(
            database,
            'password_manager',
            (PasswordManagerEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'path': item.path,
                  'password': item.password
                }),
        _passwordManagerEntityUpdateAdapter = UpdateAdapter(
            database,
            'password_manager',
            ['id'],
            (PasswordManagerEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'path': item.path,
                  'password': item.password
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PasswordManagerEntity>
      _passwordManagerEntityInsertionAdapter;

  final UpdateAdapter<PasswordManagerEntity>
      _passwordManagerEntityUpdateAdapter;

  @override
  Future<List<PasswordManagerEntity>?> findPasswordManagerByPath(
    int serverId,
    String path,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM password_manager WHERE server_id = ?1 AND path = ?2',
        mapper: (Map<String, Object?> row) => PasswordManagerEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as int,
            path: row['path'] as String,
            password: row['password'] as String),
        arguments: [serverId, path]);
  }

  @override
  Future<void> deletePasswordManagerByServerId(int serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM password_manager WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertPasswordManager(PasswordManagerEntity entity) {
    return _passwordManagerEntityInsertionAdapter.insertAndReturnId(
        entity, OnConflictStrategy.abort);
  }

  @override
  Future<int> updatePasswordManager(PasswordManagerEntity entity) {
    return _passwordManagerEntityUpdateAdapter.updateAndReturnChangedRows(
        entity, OnConflictStrategy.abort);
  }
}
