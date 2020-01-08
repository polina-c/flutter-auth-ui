import 'package:faui/faui.dart';
import 'package:flutter/material.dart';

var firebaseApiKey = "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await fauiTrySignInSilently(firebaseApiKey: firebaseApiKey);
  runApp(FlutterAuthUiDemo());
}

class FlutterAuthUiDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: HomeScreen()));
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    if (fauiUser == null) {
      return fauiBuildAuthScreen(
        () {
          if (fauiUser != null) {
            fauiSaveUserLocallyForSilentSignIn();
            setState(() {});
          }
        },
        firebaseApiKey,
      );
    }

    return Column(
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
    );
  }
}
