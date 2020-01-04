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
  bool _wantToSignIn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    if (fauiUser == null && _wantToSignIn) {
      return fauiBuildAuthScreen(
        () {
          this.setState(() {
            _wantToSignIn = false;
          });
          if (fauiUser != null) {
            fauiSaveUserLocallyForSilentSignIn();
          }
        },
        firebaseApiKey,
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

  static Widget buildDescription() {
    return Text('demo1 for flatter-auth-ui: default layout and language');
  }
}
