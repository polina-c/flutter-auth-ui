import 'package:flutter/gestures.dart';
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
    return new RichText(
      text: new TextSpan(
        children: [
          buildText('This is demo for '),
          buildLink(
              'flatter-auth-ui', 'https://github.com/polina-c/flutter-auth-ui'),
          buildText('. Find source code '),
          buildLink('here', 'https://github.com/polina-c/flutter-auth-ui-demo'),
          buildText('.'),
        ],
      ),
    );
  }

  static TextSpan buildText(String text) {
    return new TextSpan(
      text: text,
      style: new TextStyle(color: Colors.black),
    );
  }

  static TextSpan buildLink(String text, String url) {
    return new TextSpan(
      text: text + "($url)",
      style: new TextStyle(color: Colors.blue),
      recognizer: new TapGestureRecognizer()..onTap = () {},
    );
  }
}
