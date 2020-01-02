import 'package:faui/faui.dart';
import 'package:faui/FauiPhrases.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
      return Faui.buildCustomAuthScreen(
        onExit: () {
          this.setState(() {
            _wantToSignIn = false;
          });
          if (Faui.user != null) {
            Faui.saveUserLocallyForSilentSignIn();
          }
        },
        firebaseApiKey: firebaseApiKey,
        builder: authScreenBuilder,
        phrases: {FauiPhrases.SignInTitle: "Please, Sign In"},
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

  static Widget authScreenBuilder({
    @required BuildContext context,
    @required String title,
    @required Widget content,
    @required VoidCallback close,
  }) {
    const double _boxWidth = 270;
    const double _boxHeight = 380;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double vInsets = max(5, (screenHeight - _boxHeight) / 2);
    double hInsets = max(5, (screenWidth - _boxWidth) / 2);

    return Container(
      color: Colors.black87,
      padding: EdgeInsets.symmetric(vertical: vInsets, horizontal: hInsets),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: close,
                )
              ],
            ),
            body: Container(
              child: content,
              padding: EdgeInsets.all(20),
            )),
      ),
    );
  }
}
