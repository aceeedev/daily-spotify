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
      timesReshuffled: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTrack obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.track)
      ..writeByte(2)
      ..write(obj.reaction)
      ..writeByte(3)
      ..write(obj.timesReshuffled);
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
