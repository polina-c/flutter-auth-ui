import 'package:meta/meta.dart';

class FauiUser {
  final String email;
  final String userId;
  final String token;

  FauiUser({@required this.email, @required this.userId, @required this.token});

  FauiUser.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        userId = json['userId'],
        token = json['token'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'userId': userId,
        'token': token,
      };
}
