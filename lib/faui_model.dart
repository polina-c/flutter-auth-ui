class FauiUser {
  final String email;
  final String idToken;
  final String refreshToken;

  FauiUser({this.email, this.idToken, this.refreshToken});

  factory FauiUser.fromJson(Map<String, dynamic> json) {
    return FauiUser(
      email: json['email'],
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
