import 'package:flutter_web/material.dart';
import 'package:uuid/uuid.dart';

import 'FaAuthState.dart';
import 'FaExceptionAnalyser.dart';
import 'FbConnector.dart';
import 'fa_model.dart';

var uuid = new Uuid();

class FaAuthScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;
  final String firebaseApiKey;

  FaAuthScreen(
      {@required VoidCallback this.onSuccess,
      @required VoidCallback this.onCancel,
      @required String this.firebaseApiKey});

  @override
  _FaAuthScreenState createState() => _FaAuthScreenState();
}

enum AuthScreen {
  signIn,
  createAccount,
  forgotPassword,
  verifyEmail,
}

class _FaAuthScreenState extends State<FaAuthScreen> {
  AuthScreen _authScreen = AuthScreen.signIn;
  String _error;
  String _email;

  void switchScreen(AuthScreen authScreen, String email) {
    setState(() {
      this._authScreen = authScreen;
      this._error = null;
      this._email = email;
    });
  }

  void afterAuthorized(BuildContext context, FaUser user) {
    FaAuthState.User = user;
    this.widget.onSuccess();
  }

  List<Widget> getActions() {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: this.widget.onCancel,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    switch (this._authScreen) {
      case AuthScreen.signIn:
        return _buildSignInScreen(context);
      case AuthScreen.createAccount:
        return _buildCreateAccountScreen(context);
      case AuthScreen.forgotPassword:
        return _buildForgotPasswordScreen(context, this._email);
      case AuthScreen.verifyEmail:
        return _buildVerifyEmailScreen(context, this._email);
      default:
        throw "Unexpected screen $_authScreen";
    }
  }

  Widget _buildCreateAccountScreen(BuildContext context) {
    final TextEditingController emailController =
        new TextEditingController(text: this._email);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        actions: this.getActions(),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "EMail",
            ),
          ),
          Text(
            this._error ?? "",
            style: TextStyle(color: Colors.red),
          ),
          RaisedButton(
            child: Text('Create Account'),
            onPressed: () async {
              try {
                await FbConnector.registerUser(
                  apiKey: this.widget.firebaseApiKey,
                  email: emailController.text,
                  password: uuid.v4(),
                );

                await FbConnector.sendResetLink(
                  apiKey: this.widget.firebaseApiKey,
                  email: emailController.text,
                );

                this.switchScreen(AuthScreen.verifyEmail, emailController.text);
              } catch (e) {
                this.setState(() {
                  this._error = FaExceptionAnalyser.ToUiMessage(e);
                  this._email = emailController.text;
                });
              }
            },
          ),
          FlatButton(
            child: Text('Have account? Sign in.'),
            onPressed: () {
              this.switchScreen(AuthScreen.signIn, emailController.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignInScreen(BuildContext context) {
    final TextEditingController emailController =
        new TextEditingController(text: this._email);
    final TextEditingController passwordController =
        new TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        actions: this.getActions(),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "EMail",
            ),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password",
            ),
          ),
          Text(
            this._error ?? "",
            style: TextStyle(color: Colors.red),
          ),
          RaisedButton(
            child: Text('Sign In'),
            onPressed: () async {
              try {
                FaUser user = await FbConnector.signInUser(
                  apiKey: this.widget.firebaseApiKey,
                  email: emailController.text,
                  password: passwordController.text,
                );
                print("User signed in: ${user}, ${user?.email}");
                this.afterAuthorized(context, user);
              } catch (e) {
                this.setState(() {
                  this._error = FaExceptionAnalyser.ToUiMessage(e);
                  this._email = emailController.text;
                });
              }
            },
          ),
          FlatButton(
            child: Text('Create Account'),
            onPressed: () {
              this.switchScreen(AuthScreen.createAccount, emailController.text);
            },
          ),
          FlatButton(
            child: Text('Forgot Password?'),
            onPressed: () {
              FbConnector.sendResetLink(
                apiKey: this.widget.firebaseApiKey,
                email: emailController.text,
              );
              this.switchScreen(
                  AuthScreen.forgotPassword, emailController.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyEmailScreen(BuildContext context, String email) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        actions: this.getActions(),
      ),
      body: Column(
        children: <Widget>[
          Text("We sent verification link to $email"),
          FlatButton(
            child: Text('Sign In'),
            onPressed: () {
              this.switchScreen(AuthScreen.signIn, email);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordScreen(BuildContext context, String email) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        actions: this.getActions(),
      ),
      body: Column(
        children: <Widget>[
          Text("We sent password reset instructions to $email"),
          FlatButton(
            child: Text('Sign In'),
            onPressed: () {
              this.switchScreen(AuthScreen.signIn, email);
            },
          ),
        ],
      ),
    );
  }
}
