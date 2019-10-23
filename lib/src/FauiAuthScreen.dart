import 'dart:math';

import 'package:faui/FauiPhrases.dart';
import 'package:faui/src/DefaultScreenBuilder.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../FauiUser.dart';
import '../FbConnector.dart';
import 'FauiAuthState.dart';
import 'FauiExceptionAnalyser.dart';

var uuid = new Uuid();

class FauiAuthScreen extends StatefulWidget {
  final VoidCallback onExit;
  final String firebaseApiKey;
  final bool startWithRegistration;
  final Map<FauiPhrases, String> phrases;
  final Widget Function(BuildContext context, String title, Widget content,
      VoidCallback close) builder;

  FauiAuthScreen(
      {@required this.onExit,
      @required this.firebaseApiKey,
      this.startWithRegistration})
      : this.builder = DefaultScreenBuilder.builder,
        this.phrases = Map<FauiPhrases, String>();

  FauiAuthScreen.custom({
    @required this.onExit,
    @required this.firebaseApiKey,
    @required this.builder,
    @required this.phrases,
    this.startWithRegistration,
  });

  @override
  _FauiAuthScreenState createState() => _FauiAuthScreenState();
}

enum AuthScreen {
  signIn,
  createAccount,
  forgotPassword,
  verifyEmail,
  resetPassword,
}

class _FauiAuthScreenState extends State<FauiAuthScreen> {
  static const double _boxWidth = 200;
  static const double _boxHeight = 400;

  AuthScreen _authScreen = AuthScreen.signIn;
  String _error;
  String _email;

  @override
  void initState() {
    super.initState();

    if (this.widget.startWithRegistration) {
      this._authScreen = AuthScreen.createAccount;
    }
  }

  void switchScreen(AuthScreen authScreen, String email) {
    setState(() {
      this._authScreen = authScreen;
      this._error = null;
      this._email = email;
    });
  }

  void afterAuthorized(BuildContext context, FauiUser user) {
    FauiAuthState.user = user;
    this.widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double vInsets = max(5, (screenHeight - _boxHeight) / 2);
    double hInsets = max(5, (screenWidth - _boxWidth) / 2);
    return Card(
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: vInsets, horizontal: hInsets),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: Theme.of(context).textTheme.title.fontSize,
                    ),
                    onPressed: this.widget.onExit,
                  ),
                ],
              ),
              Text(
                _getScreenTitle(),
                style: Theme.of(context).textTheme.title,
              ),
              _getScreen(context),
            ],
          ),
        ),
      ),
    );
  }

  String _getScreenTitle() {
    switch (this._authScreen) {
      case AuthScreen.signIn:
        return 'Sign In';
      case AuthScreen.createAccount:
        return 'Create Account';
      case AuthScreen.forgotPassword:
        return 'Forgot Password';
      case AuthScreen.verifyEmail:
        return 'Verify Email';
      case AuthScreen.resetPassword:
        return 'Reset Password';
      default:
        throw "Unexpected screen $_authScreen";
    }
  }

  Widget _getScreen(BuildContext context) {
    switch (this._authScreen) {
      case AuthScreen.signIn:
        return _buildSignInScreen(context);
      case AuthScreen.createAccount:
        return _buildCreateAccountScreen(context);
      case AuthScreen.forgotPassword:
        return _buildForgotPasswordScreen(context, this._email);
      case AuthScreen.verifyEmail:
        return _buildVerifyEmailScreen(context, this._email);
      case AuthScreen.resetPassword:
        return _buildResetPasswordScreen(context, this._email);
      default:
        throw "Unexpected screen $_authScreen";
    }
  }

  static Widget _buildError(BuildContext context, String error) {
    return Text(
      error ?? "",
      style: TextStyle(color: Theme.of(context).errorColor),
    );
  }

  Widget _buildCreateAccountScreen(BuildContext context) {
    final TextEditingController emailController =
        new TextEditingController(text: this._email);
    return Column(children: <Widget>[
      TextField(
        autofocus: true,
        controller: emailController,
        decoration: InputDecoration(
          labelText: "EMail",
        ),
      ),
      _buildError(context, _error),
      RaisedButton(
        autofocus: true,
        child: Text('Create Account'),
        onPressed: () async {
          try {
            await FbConnector.registerUser(
              apiKey: this.widget.firebaseApiKey,
              email: emailController.text,
            );

            await FbConnector.sendResetLink(
              apiKey: this.widget.firebaseApiKey,
              email: emailController.text,
            );

            this.switchScreen(AuthScreen.verifyEmail, emailController.text);
          } catch (e) {
            this.setState(() {
              this._error = FauiExceptionAnalyser.toUiMessage(e);
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
    ]);
  }

  Widget _buildSignInScreen(BuildContext context) {
    final TextEditingController emailController =
        new TextEditingController(text: this._email);
    final TextEditingController passwordController =
        new TextEditingController();

    return Column(
      children: <Widget>[
        TextField(
          autofocus: true,
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
        _buildError(context, _error),
        RaisedButton(
          child: Text('Sign In'),
          onPressed: () async {
            try {
              FauiUser user = await FbConnector.signInUser(
                apiKey: this.widget.firebaseApiKey,
                email: emailController.text,
                password: passwordController.text,
              );
              this.afterAuthorized(context, user);
            } catch (e) {
              this.setState(() {
                this._error = FauiExceptionAnalyser.toUiMessage(e);
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
            this.switchScreen(AuthScreen.forgotPassword, emailController.text);
          },
        ),
      ],
    );
  }

  Widget _buildVerifyEmailScreen(BuildContext context, String email) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: Text("We sent verification link to $email"),
        ),
        RaisedButton(
          child: Text('Sign In'),
          onPressed: () {
            this.switchScreen(AuthScreen.signIn, email);
          },
        ),
      ],
    );
  }

  Widget _buildResetPasswordScreen(BuildContext context, String email) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: Text("We sent the link to reset your password to $email"),
        ),
        RaisedButton(
          child: Text('Sign In'),
          onPressed: () {
            this.switchScreen(AuthScreen.signIn, email);
          },
        ),
      ],
    );
  }

  Widget _buildForgotPasswordScreen(BuildContext context, String email) {
    final TextEditingController emailController =
        new TextEditingController(text: this._email);

    return Column(
      children: <Widget>[
        TextField(
          autofocus: true,
          controller: emailController,
          decoration: InputDecoration(
            labelText: "EMail",
          ),
        ),
        _buildError(context, _error),
        RaisedButton(
          child: Text('Send Password Reset Link'),
          onPressed: () async {
            try {
              await FbConnector.sendResetLink(
                apiKey: this.widget.firebaseApiKey,
                email: emailController.text,
              );
              this.switchScreen(AuthScreen.resetPassword, emailController.text);
            } catch (e) {
              this.setState(() {
                this._error = FauiExceptionAnalyser.toUiMessage(e);
                this._email = emailController.text;
              });
            }
          },
        ),
        FlatButton(
          child: Text('Sign In'),
          onPressed: () {
            this.switchScreen(AuthScreen.signIn, email);
          },
        ),
        FlatButton(
          child: Text('Create Account'),
          onPressed: () {
            this.switchScreen(AuthScreen.createAccount, email);
          },
        ),
      ],
    );
  }
}
