// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MusicAdapter extends TypeAdapter<Music> {
  @override
  final int typeId = 0;

  @override
  Music read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Music(
      fields[0] as String,
      (fields[1] as List).cast<String>(),
      fields[2] as String,
      fields[3] as int,
      fields[4] as int,
      (fields[5] as List).cast<int>(),
      fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Music obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.artistNames)
      ..writeByte(2)
      ..write(obj.albumName)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.cover)
      ..writeByte(6)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
