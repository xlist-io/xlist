import 'package:floor/floor.dart';

@Entity(
  tableName: 'progress',
  indices: [
    Index(value: ['server_id', 'path', 'name'], unique: true),
  ],
)
class ProgressEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  final int serverId;

  @ColumnInfo(name: 'path')
  final String path;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'current_pos')
  final int currentPos;

  ProgressEntity({
    this.id,
    required this.serverId,
    required this.path,
    required this.name,
    required this.currentPos,
  });
}
