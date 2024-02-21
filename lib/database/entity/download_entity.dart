import 'package:floor/floor.dart';

@Entity(
  tableName: 'download',
  indices: [
    Index(value: ['server_id', 'path', 'name'], unique: true),
    Index(value: ['task_id'], unique: false),
  ],
)
class DownloadEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  final int serverId;

  @ColumnInfo(name: 'task_id')
  final String taskId;

  @ColumnInfo(name: 'type')
  final int type;

  @ColumnInfo(name: 'path')
  final String path;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'size')
  final int size;

  DownloadEntity({
    this.id,
    required this.serverId,
    required this.taskId,
    required this.type,
    required this.path,
    required this.name,
    required this.size,
  });
}
