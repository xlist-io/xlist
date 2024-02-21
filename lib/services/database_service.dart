import 'dart:io';

import 'package:get/get.dart';
import 'package:floor/floor.dart';

import 'package:xlist/database/database.dart';

// Database used floor
class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find();

  // AppDatabase
  late XlistDatabase _database;
  XlistDatabase get database => _database;

  // Database name
  String name = 'xlist_database.db';

  // Database migration1to2
  final migration1to2 = Migration(1, 2, (database) async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS `recent` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` INTEGER NOT NULL, `path` TEXT NOT NULL, `name` TEXT NOT NULL, `type` INTEGER NOT NULL, `size` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL)');
    await database.execute(
        'CREATE UNIQUE INDEX `index_recent_server_id_path_name` ON `recent` (`server_id`, `path`, `name`)');
    await database.execute(
        'CREATE INDEX `index_recent_updated_at` ON `recent` (`updated_at`)');
  });

  // Database migration2to3
  final migration2to3 = Migration(2, 3, (database) async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS `favorite` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` INTEGER NOT NULL, `path` TEXT NOT NULL, `name` TEXT NOT NULL, `type` INTEGER NOT NULL, `size` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL)');
    await database.execute(
        'CREATE UNIQUE INDEX `index_favorite_server_id_path_name` ON `favorite` (`server_id`, `path`, `name`)');
    await database.execute(
        'CREATE INDEX `index_favorite_updated_at` ON `favorite` (`updated_at`)');
  });

  // Init
  Future<DatabaseService> init() async {
    _database = await $FloorXlistDatabase
        .databaseBuilder(name)
        .addMigrations([migration1to2, migration2to3]).build();

    return this;
  }

  // 获取大小
  Future<int> getSize() async {
    return File(await sqfliteDatabaseFactory.getDatabasePath(name)).length();
  }
}
