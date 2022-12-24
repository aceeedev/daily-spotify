// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_token.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccessTokenAdapter extends TypeAdapter<AccessToken> {
  @override
  final int typeId = 1;

  @override
  AccessToken read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccessToken(
      accessToken: fields[0] as String,
      tokenType: fields[1] as String,
      scope: fields[2] as String,
      expiresIn: fields[3] as int,
      createdAt: fields[4] as DateTime,
      refreshToken: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AccessToken obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.tokenType)
      ..writeByte(2)
      ..write(obj.scope)
      ..writeByte(3)
      ..write(obj.expiresIn)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.refreshToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessTokenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
