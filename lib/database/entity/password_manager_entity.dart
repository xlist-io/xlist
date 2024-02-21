import 'package:floor/floor.dart';

@Entity(
  tableName: 'password_manager',
  indices: [
    Index(value: ['server_id', 'path'], unique: false),
  ],
)
class PasswordManagerEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  final int serverId;

  @ColumnInfo(name: 'path')
  final String path;

  @ColumnInfo(name: 'password')
  final String password;

  PasswordManagerEntity({
    this.id,
    required this.serverId,
    required this.path,
    required this.password,
  });
}
