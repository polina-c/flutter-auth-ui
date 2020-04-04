import 'package:flutter/material.dart';

class AuthProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container (
        child: Column (
          children: <Widget> [
            new Container(
              width: 40, height: 40, child: CircularProgressIndicator(),
            ),
          ],
        ));
  }
}