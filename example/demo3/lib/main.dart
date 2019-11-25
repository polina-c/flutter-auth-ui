import 'package:faui/FauiDb.dart';
import 'package:faui/faui.dart';
import 'package:faui/widgets/FauiTextField.dart';
import 'package:flutter/material.dart';

FauiDb db = FauiDb(
  apiKey: "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4",
  db: "(default)",
  projectId: "flutterauth-c3973",
);

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Faui.trySignInSilently(firebaseApiKey: db.apiKey);
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
    _loadValue();
  }

  _loadValue() async {
    // CoachProfile profile = await XfData.select<CoachProfile>(
    //   id: widget.profileId,
    //   token: UiConfig.currentUserToken,
    // );

    // this.setState(() {
    //   _profile = profile;
    // });
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
        firebaseApiKey: db.apiKey,
      );
    }

    return Column(
      children: <Widget>[
        buildDescription(),
        Text("Hello, ${Faui.user.email}!"),
        Text(
            "Faui widgets can store data as you type, securely, and without server:"),
        FauiTextField(
          db,
          Faui.user,
          decoration: InputDecoration(
            labelText: "FauiTextField",
          ),
        ),
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
    return Text('demo3 for flatter-auth-ui: Store Input as User Types');
  }
}
