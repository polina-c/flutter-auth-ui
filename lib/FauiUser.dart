class FauiUser {
  final String email;
  final String userId;
  final String token;
  final String refreshToken;

  FauiUser({this.email, this.userId, this.token, this.refreshToken});

  FauiUser.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        userId = json['userId'],
        token = json['token'],
        refreshToken = json['refreshToken'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'userId': userId,
        'token': token,
        'refreshToken': refreshToken,
      };
}
