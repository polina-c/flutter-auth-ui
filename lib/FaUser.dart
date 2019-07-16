class FaUser {
  final String email;
  final String idToken;
  final String refreshToken;

  FaUser({this.email, this.idToken, this.refreshToken});

  factory FaUser.fromJson(Map<String, dynamic> json) {
    return FaUser(
      email: json['email'],
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
