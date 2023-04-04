// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpotifyImageAdapter extends TypeAdapter<SpotifyImage> {
  @override
  final int typeId = 3;

  @override
  SpotifyImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpotifyImage(
      height: fields[0] as int,
      url: fields[1] as String,
      width: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SpotifyImage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.height)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.width);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotifyImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
