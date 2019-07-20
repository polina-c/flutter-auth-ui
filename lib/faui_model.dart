import 'FauiUtil.dart';

class FauiUser {
  final String email;
  final String idToken;
  final String refreshToken;
  final String userId;

  FauiUser({this.email, this.idToken, this.refreshToken, this.userId});

  factory FauiUser.fromJson(Map<String, dynamic> json) {
    return FauiUser(
      email: json['email'],
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
      userId: FauiUtil.parseJwt(json['idToken'])["userId"],
    );
  }
}
