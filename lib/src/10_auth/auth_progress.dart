import 'package:flutter/material.dart';

class AuthProgress extends StatelessWidget {
final String email;
final String intent;

AuthProgress(this.email, this.intent);

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
    child: Container(
    height: MediaQuery.of(context).size.height * 0.40,
    width: MediaQuery.of(context).size.width * 0.40,
    child: Column(
    children: <Widget>[
      Text(this.email,
        style: TextStyle(color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 15)
      ),
    Padding(
    padding: const EdgeInsets.all(20.0),
    child: CircularProgressIndicator(),
    ),
    Text(this.intent,
    style: TextStyle(color: Colors.black,
    fontWeight: FontWeight.normal,
    fontSize: 15)
    ),
    ])),
  ));
  }
}


