import 'package:hive/hive.dart';

class VaultItem extends HiveObject {
  String id;
  String title;
  String username;
  List<String> versionIds;

  VaultItem({
    required this.id,
    required this.title,
    required this.versionIds,
    this.username = '',
  });
}

class VaultItemAdapter extends TypeAdapter<VaultItem> {
  @override
  final typeId = 0;

  @override
  VaultItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaultItem(
      id: fields[0] as String,
      title: fields[1] as String,
      versionIds: (fields[2] as List).cast<String>(),
      // field 3 is new — defaults to '' for existing entries (migration safe)
      username: fields[3] == null ? '' : fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VaultItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.versionIds)
      ..writeByte(3)
      ..write(obj.username);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VaultItemAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}