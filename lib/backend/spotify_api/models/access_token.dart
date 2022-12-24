import 'package:hive/hive.dart';

part 'access_token.g.dart';

@HiveType(typeId: 1)
class AccessToken {
  @HiveField(0)
  String accessToken;
  @HiveField(1)
  String tokenType;
  @HiveField(2)
  String scope;
  @HiveField(3)
  int expiresIn;
  @HiveField(4)
  DateTime createdAt;
  late DateTime expiresAt;
  @HiveField(5)
  String refreshToken;

  AccessToken(
      {required this.accessToken,
      required this.tokenType,
      required this.scope,
      required this.expiresIn,
      required this.createdAt,
      required this.refreshToken}) {
    expiresAt = createdAt.add(Duration(seconds: expiresIn));
  }
}
