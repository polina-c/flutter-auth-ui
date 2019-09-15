import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'FauiAuthState.dart';
import 'FauiExceptionAnalyser.dart';
import 'FbConnector.dart';
import 'faui_model.dart';

var uuid = new Uuid();

class FauiAuthScreen extends StatefulWidget {
  final VoidCallback onExit;
  final String firebaseApiKey;
  final bool startWithRegistration;

  FauiAuthScreen(
      {@required this.onExit,
      @required this.firebaseApiKey,
      this.startWithRegistration});

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
  static const double _BoxWidth = 500;
  static const double _BoxHeight = 500;
  static const double _MinMargin = 20;
  static const double _Padding = 5;

  AuthScreen _authScreen = AuthScreen.signIn;
  String _error;
  String _email;

  FocusNode _passwordFocus;
  FocusNode _emailFocus;

  @override
  void initState() {
    super.initState();

    if (this.widget.startWithRegistration) {
      this._authScreen = AuthScreen.createAccount;
    }

    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  void switchScreen(AuthScreen authScreen, String email) {
    setState(() {
      this._authScreen = authScreen;
      this._error = null;
      this._email = email;
    });
  }

  void afterAuthorized(BuildContext context, FauiUser user) {
    FauiAuthState.User = user;
    this.widget.onExit();
  }

  List<Widget> getActions() {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: this.widget.onExit,
      )
    ];
  }

  static bool _IsSmall(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return (screenWidth < _BoxWidth + _MinMargin) ||
        (screenHeight < _BoxHeight + _MinMargin);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmall = _IsSmall(context);

    return Container(
      color: Colors.black87,
      padding: isSmall
          ? null
          : EdgeInsets.symmetric(
              vertical: (screenHeight - _BoxHeight) / 2,
              horizontal: (screenWidth - _BoxWidth) / 2),
      child: ClipRRect(
        borderRadius: isSmall
            ? BorderRadius.all(Radius.circular(0))
            : BorderRadius.all(Radius.circular(3)),
        child: _getScreen(context),
      ),
    );
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

  Widget _buildCreateAccountScreen(BuildContext context) {
    final TextEditingController emailController =
        new TextEditingController(text: this._email);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        actions: this.getActions(),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: _Padding),
          width: _BoxWidth - _Padding * 2,
          child: Column(
            children: <Widget>[
              TextField(
                autofocus: true,
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
                    await FbConnector.RegisterUser(
                      apiKey: this.widget.firebaseApiKey,
                      email: emailController.text,
                    );

                    await FbConnector.SendResetLink(
                      apiKey: this.widget.firebaseApiKey,
                      email: emailController.text,
                    );

                    this.switchScreen(
                        AuthScreen.verifyEmail, emailController.text);
                  } catch (e) {
                    this.setState(() {
                      this._error = FauiExceptionAnalyser.ToUiMessage(e);
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
        ),
      ),
    );
  }

  Widget _buildSignInScreen(BuildContext context) {
    final TextEditingController emailController =
        new TextEditingController(text: this._email);
    final TextEditingController passwordController =
        new TextEditingController();

    // TODO: find other way to prevent default
    // document.addEventListener('keydown', (dynamic event) {
    //   if (event.code == 'Tab') {
    //     event.preventDefault();
    //   }
    // });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign In',
        ),
        actions: this.getActions(),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 50.0),
          width: 400.0,
          child: Column(
            children: <Widget>[
              RawKeyboardListener(
                child: TextField(
                  autofocus: true,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "EMail",
                  ),
                ),
                onKey: (dynamic key) {
                  if (key.data.keyCode == 9) {
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  }
                },
                focusNode: _emailFocus,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                focusNode: _passwordFocus,
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
                    FauiUser user = await FbConnector.SignInUser(
                      apiKey: this.widget.firebaseApiKey,
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    this.afterAuthorized(context, user);
                  } catch (e) {
                    this.setState(() {
                      this._error = FauiExceptionAnalyser.ToUiMessage(e);
                      this._email = emailController.text;
                    });
                  }
                },
              ),
              FlatButton(
                child: Text('Create Account'),
                onPressed: () {
                  this.switchScreen(
                      AuthScreen.createAccount, emailController.text);
                },
              ),
              FlatButton(
                child: Text('Forgot Password?'),
                onPressed: () {
                  this.switchScreen(
                      AuthScreen.forgotPassword, emailController.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyEmailScreen(BuildContext context, String email) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        actions: this.getActions(),
      ),
      body: Center(
        child: Container(
          width: 400.0,
          child: Column(
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
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordScreen(BuildContext context, String email) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        actions: this.getActions(),
      ),
      body: Center(
        child: Container(
          width: 400.0,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child:
                    Text("We sent the link to reset your password to $email"),
              ),
              RaisedButton(
                child: Text('Sign In'),
                onPressed: () {
                  this.switchScreen(AuthScreen.signIn, email);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordScreen(BuildContext context, String email) {
    final TextEditingController emailController =
        new TextEditingController(text: this._email);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        actions: this.getActions(),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 50.0),
          width: 400.0,
          child: Column(
            children: <Widget>[
              TextField(
                autofocus: true,
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
                child: Text('Send Password Reset Link'),
                onPressed: () async {
                  try {
                    await FbConnector.SendResetLink(
                      apiKey: this.widget.firebaseApiKey,
                      email: emailController.text,
                    );
                    this.switchScreen(
                        AuthScreen.resetPassword, emailController.text);
                  } catch (e) {
                    this.setState(() {
                      this._error = FauiExceptionAnalyser.ToUiMessage(e);
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
          ),
        ),
      ),
    );
  }
}
