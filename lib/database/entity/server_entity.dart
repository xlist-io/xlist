import 'package:floor/floor.dart';

@Entity(
  tableName: 'server',
  indices: [
    Index(value: ['url'], unique: false),
  ],
)
class ServerEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'url')
  final String url;

  @ColumnInfo(name: 'type')
  final int type;

  @ColumnInfo(name: 'username')
  final String username;

  @ColumnInfo(name: 'password')
  final String password;

  ServerEntity({
    this.id,
    required this.url,
    required this.type,
    required this.username,
    required this.password,
  });
}
