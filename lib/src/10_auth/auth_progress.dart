import 'package:flutter/material.dart';

class AuthProgress extends StatelessWidget {
  final String email;

  AuthProgress(this.email);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.40,
    width: MediaQuery.of(context).size.width * 0.40,
    child: Column(
        children: [
              Text(this.email),
              Text("Loading....."),
            ]),
    );
  }
}