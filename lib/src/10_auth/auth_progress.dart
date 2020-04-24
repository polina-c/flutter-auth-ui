import 'package:flutter/material.dart';

class AuthProgress extends StatelessWidget {
  final String displayMessage;

  AuthProgress(this.displayMessage);
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.15,
        color: Colors.white,
        child: Column(
            children: <Widget>[
              CircularProgressIndicator(),
              Text(displayMessage,
                  style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.normal,
                  )),
            ]));
  }
}