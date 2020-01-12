import 'package:faui/faui.dart';
import 'package:flutter/material.dart';

var firebaseApiKey = "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await fauiTrySignInSilently(firebaseApiKey: firebaseApiKey);
  runApp(FlutterAuthUiDemo());
}

class FlutterAuthUiDemo extends StatefulWidget {
  @override
  _FlutterAuthUiDemoState createState() => _FlutterAuthUiDemoState();
}

class _FlutterAuthUiDemoState extends State<FlutterAuthUiDemo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: fauiUser == null
          ? fauiBuildAuthScreen(
              () {
                setState(() {});
              },
              firebaseApiKey,
            )
          : Scaffold(
              body: Column(
                children: <Widget>[
                  Text("Hello, ${fauiUser.email}"),
                  RaisedButton(
                    child: Text("Sign Out"),
                    onPressed: () {
                      fauiSignOut();
                      this.setState(() {});
                    },
                  )
                ],
              ),
            ),
    );
  }
}
