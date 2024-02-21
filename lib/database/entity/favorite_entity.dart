import 'package:floor/floor.dart';

@Entity(
  tableName: 'favorite',
  indices: [
    Index(value: ['server_id', 'path', 'name'], unique: true),
    Index(value: ['updated_at']),
  ],
)
class FavoriteEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  final int serverId;

  @ColumnInfo(name: 'path')
  final String path;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'type')
  final int type;

  @ColumnInfo(name: 'size')
  final int size;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  FavoriteEntity({
    this.id,
    required this.serverId,
    required this.path,
    required this.name,
    required this.type,
    required this.size,
    required this.updatedAt,
  });
}
