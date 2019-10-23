import 'package:faui/faui.dart';
import 'package:flutter/material.dart';

var firebaseApiKey = "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Faui.trySignInSilently(firebaseApiKey: firebaseApiKey);
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
    if (Faui.user == null && !_wantToSignIn) {
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

    if (Faui.user == null && _wantToSignIn) {
      return Faui.buildAuthScreen(
        onExit: () {
          this.setState(() {
            _wantToSignIn = false;
          });
          if (Faui.user != null) {
            Faui.saveUserLocallyForSilentSignIn();
          }
        },
        firebaseApiKey: firebaseApiKey,
      );
    }

    return Column(
      children: <Widget>[
        buildDescription(),
        Text("Hello, ${Faui.user.email}"),
        RaisedButton(
          child: Text("Sign Out"),
          onPressed: () {
            Faui.signOut();
            this.setState(() {});
          },
        )
      ],
    );
  }

  static Widget buildDescription() {
    return Text('demo2 for flatter-auth-ui: custom layout and language');
  }
}
