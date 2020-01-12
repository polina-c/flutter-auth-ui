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
  bool _wantToSignIn = false;

  @override
  Widget build(BuildContext context) {
    if (fauiUser == null && _wantToSignIn) {
      return MaterialApp(
          home: fauiBuildAuthScreen(
        () {
          this.setState(() {
            _wantToSignIn = false;
          });
          if (fauiUser != null) {
            fauiSaveUserLocallyForSilentSignIn();
          }
        },
        firebaseApiKey,
      ));
    }

    return MaterialApp(
        home: Scaffold(
      body: buildBody(context),
    ));
  }

  static Widget buildDescription() {
    return Text('demo for flatter-auth-ui: default layout and language');
  }

  buildBody(BuildContext context) {
    if (fauiUser == null && !_wantToSignIn) {
      return Column(
        children: <Widget>[
          buildDescription(),
          RaisedButton(
            child: Text("Sign In"),
            onPressed: () {
              this.setState(() {
                _wantToSignIn = true;
              });
            },
          )
        ],
      );
    }

    return Column(
      children: <Widget>[
        buildDescription(),
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
