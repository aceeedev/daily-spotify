// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyTrackAdapter extends TypeAdapter<DailyTrack> {
  @override
  final int typeId = 5;

  @override
  DailyTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyTrack(
      date: fields[0] as DateTime,
      track: fields[1] as Track,
      reaction: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTrack obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.track)
      ..writeByte(2)
      ..write(obj.reaction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
