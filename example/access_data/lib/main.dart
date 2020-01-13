import 'package:faui/faui.dart';
import 'package:flutter/material.dart';

FauiDb _fauiDb = FauiDb(
  "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4",
  "(default)",
  "flutterauth-c3973",
);

const String _collection = 'access-data-demo-user';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await fauiTrySignInSilently(firebaseApiKey: _fauiDb.apiKey);
  runApp(FlutterAuthUiDemo());
}

class FlutterAuthUiDemo extends StatefulWidget {
  @override
  _FlutterAuthUiDemoState createState() => _FlutterAuthUiDemoState();
}

class _FlutterAuthUiDemoState extends State<FlutterAuthUiDemo> {
  TextEditingController _firstCtrl = TextEditingController();
  TextEditingController _lastCtrl = TextEditingController();
  Map<String, dynamic> _doc;

  @override
  void initState() {
    if (fauiUser != null) {
      _loadData();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: fauiUser == null
          ? fauiBuildAuthScreen(
              _processSignIn,
              _fauiDb.apiKey,
            )
          : Scaffold(
              body: Container(
                width: 600,
                height: 600,
                padding: EdgeInsets.all(60),
                child: _buildContent(),
              ),
            ),
    );
  }

  Widget _buildContent() {
    if (_doc == null) {
      return Column(
        children: <Widget>[
          Text("Hello, ${fauiUser.email}. We are loading your data..."),
          _buildSignOutButton(),
        ],
      );
    }

    return Column(
      children: <Widget>[
        Text("Hello, ${fauiUser.email}."),
        Text("Your stored values are: first name '${_firstCtrl.value.text}', "
            "last name '${_lastCtrl.value.text}'"),
        TextField(
          controller: _firstCtrl,
          decoration: InputDecoration(
            labelText: "First Name",
          ),
        ),
        TextField(
          controller: _lastCtrl,
          decoration: InputDecoration(
            labelText: "Last Name",
          ),
        ),
        RaisedButton(
          child: Text("Save"),
          onPressed: _saveData,
        ),
        _buildSignOutButton(),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return RaisedButton(
      child: Text("Sign Out"),
      onPressed: _signOut,
    );
  }

  void _signOut() {
    _doc = null;
    fauiSignOut();
    setState(() => {});
  }

  Future<void> _processSignIn() async {
    if (fauiUser != null) {
      fauiSaveUserLocallyForSilentSignIn();
    }
    setState(() {});
    await _loadData();
  }

  Future<void> _loadData() async {
    _doc = await FauiDbAccess(_fauiDb, fauiUser.token).loadDoc(
          _collection,
          fauiUser.userId,
        ) ??
        {"first": "", "last": ""};
    _firstCtrl.text = _doc["first"];
    _lastCtrl.text = _doc["last"];

    setState(() => {});
  }

  Future<void> _saveData() async {
    _doc = {
      "first": _firstCtrl.text,
      "last": _lastCtrl.text,
    };

    await FauiDbAccess(_fauiDb, fauiUser.token).saveDoc(
      _collection,
      fauiUser.userId,
      _doc,
    );

    setState(() => {});
  }
}
