import 'dart:async';

import 'package:flutter/material.dart';

import '../90_infra/faui_error.dart';
import '../90_model/faui_phrases.dart';
import '../90_model/faui_user.dart';
import 'auth_progress.dart';
import 'auth_connector.dart';
import 'auth_state.dart';
import 'default_screen_builder.dart';

class FauiAuthScreen extends StatefulWidget {
  final VoidCallback onExit;
  final String firebaseApiKey;
  final bool startWithRegistration;
  final Map<FauiPhrases, String> phrases;

  final Widget Function(
    BuildContext context,
    String title,
    Widget content,
    VoidCallback close,
  ) builder;

  FauiAuthScreen(this.onExit, this.firebaseApiKey, this.startWithRegistration)
      : this.builder = DefaultScreenBuilder.builder,
        this.phrases = Map<FauiPhrases, String>();

  FauiAuthScreen.custom(
    this.onExit,
    this.firebaseApiKey,
    this.builder,
    this.phrases,
    this.startWithRegistration,
  );

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
  AuthScreen _authScreen = AuthScreen.signIn;
  String _error;
  String _email;
  bool _onExitInvoked = false;
  bool _loadingCreateAccount = false;
  bool _loadingSignIn = false;
  bool _loadingForgotPassword = false;

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
    if (!_onExitInvoked) {
      _onExitInvoked = true;
      this.widget.onExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(
        context, _getScreenTitle(), _getScreen(context), this.widget.onExit);
  }

  String _getScreenTitle() {
    switch (this._authScreen) {
      case AuthScreen.signIn:
        return widget.phrases[FauiPhrases.SignInTitle] ?? 'Sign In';
      case AuthScreen.createAccount:
        return widget.phrases[FauiPhrases.CreateAccountTitle] ??
            'Create Account';
      case AuthScreen.forgotPassword:
        return widget.phrases[FauiPhrases.ForgotPassordTitle] ??
            'Forgot Password';
      case AuthScreen.verifyEmail:
        return widget.phrases[FauiPhrases.VerifyEmailTitle] ?? 'Verify Email';
      case AuthScreen.resetPassword:
        return widget.phrases[FauiPhrases.ResetPasswordTitle] ??
            'Reset Password';
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

    final submit = () async {
      try {
        if (_loadingCreateAccount == true) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AuthProgress(emailController.text,"Creating account");
              });
        }
        await Future.delayed(Duration(seconds: 5));
        await fauiRegisterUser(
          apiKey: this.widget.firebaseApiKey,
          email: emailController.text,
        );
        if (_loadingCreateAccount == true) {
          _loadingCreateAccount = false;
          Navigator.pop(context);
        }
        this.switchScreen(AuthScreen.verifyEmail, emailController.text);
      } catch (e) {
        _loadingCreateAccount = false;
        Navigator.pop(context);
        this.setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = emailController.text;
        });
      }
    };

    return Column(children: <Widget>[
      TextField(
        autofocus: true,
        controller: emailController,
        decoration: InputDecoration(
          labelText: widget.phrases[FauiPhrases.EmailTextField] ?? "EMail",
        ),
        onSubmitted: (s) {
          submit();
        },
      ),
      _buildError(context, _error),
      RaisedButton(
        child: Text(widget.phrases[FauiPhrases.CreateAccountButton] ??
            'Create Account'),
        onPressed: submit,
      ),
      FlatButton(
        child: Text(widget.phrases[FauiPhrases.HaveAccountLink] ??
            'Have account? Sign in.'),
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

    final submit = () async {
      try {
        if (_loadingSignIn == true) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AuthProgress(emailController.text, "Signing in");
              });
        }
        await Future.delayed(Duration(seconds: 5));
        FauiUser user = await fauiSignInUser(
          apiKey: this.widget.firebaseApiKey,
          email: emailController.text,
          password: passwordController.text,
        );
        if (_loadingSignIn == true) {
          _loadingSignIn = false;
          Navigator.pop(context);
        }
        this.afterAuthorized(context, user);
      } catch (e) {
        if (_loadingSignIn == true) {
          _loadingSignIn = false;
          Navigator.pop(context);
        }
        setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = emailController.text;
        });
      }
    };

    return Column(
      children: <Widget>[
        TextField(
          controller: emailController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.phrases[FauiPhrases.EmailTextField] ?? "EMail",
          ),
          onSubmitted: (s) {
            submit();
          },
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText:
                widget.phrases[FauiPhrases.PasswordTextField] ?? "Password",
          ),
          onSubmitted: (s) {
            submit();
          },
        ),
        _buildError(context, _error),
        RaisedButton(
          child: Text(widget.phrases[FauiPhrases.SignInButton] ?? 'Sign In'),
          onPressed: () {
            _loadingSignIn = true;
            submit();
          }
    ),
    FlatButton(
    child: Text(
    widget.phrases[FauiPhrases.CreateAccountLink] ??
              'Create Account'),
          onPressed: () {
            _loadingCreateAccount = true;
            this.switchScreen(AuthScreen.createAccount, emailController.text);
          },
        ),
        FlatButton(
          child: Text(widget.phrases[FauiPhrases.ForgotPassordLink] ??
              'Forgot Password?'),
          onPressed: () {
            _loadingForgotPassword = true;
            this.switchScreen(AuthScreen.forgotPassword, emailController.text);
          },
        ),
      ],
    );
  }

  Widget _buildVerifyEmailScreen(BuildContext context, String email) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.phrases[FauiPhrases.WeSentVerificationEmailMessage] ??
              "We sent verification link to $email",
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: Text(widget.phrases[FauiPhrases.SignInButton] ?? 'Sign In'),
          onPressed: () {
            this.switchScreen(AuthScreen.signIn, email);
          },
        ),
      ],
    );
  }

  Widget _buildResetPasswordScreen(BuildContext context, String email) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.phrases[FauiPhrases.WeSentLinkToResetPasswordMEssage] ??
              "We sent the link to reset your password to $email",
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: Text(widget.phrases[FauiPhrases.SignInButton] ?? 'Sign In'),
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

    final submit = () async {
      try {
        if (_loadingForgotPassword == true && emailController.text != null) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AuthProgress(emailController.text,"Sending Password Reset");
              });
        }
        await Future.delayed(Duration(seconds: 5));
        await fauiSendResetLink(
          apiKey: this.widget.firebaseApiKey,
          email: emailController.text,
        );
        if (_loadingForgotPassword == true) {
          Navigator.pop(context);
          _loadingForgotPassword = false;
        };
        this.switchScreen(AuthScreen.resetPassword, emailController.text);
      } catch (e) {
        _loadingForgotPassword = false;
        Navigator.pop(context);
        setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = emailController.text;
        });
      }
    };

    return Column(
      children: <Widget>[
        TextField(
          autofocus: true,
          controller: emailController,
          decoration: InputDecoration(
            labelText: widget.phrases[FauiPhrases.EmailTextField] ?? "EMail",
          ),
          onSubmitted: (s) {
            submit();
          },
        ),
        _buildError(context, _error),
        RaisedButton(
          child: Text(widget.phrases[FauiPhrases.SendPasswordResetLinkButton] ??
              'Send Password Reset Link'),
          onPressed: submit,
        ),
        FlatButton(
          child: Text(widget.phrases[FauiPhrases.SignInLink] ?? 'Sign In'),
          onPressed: () {
            this.switchScreen(AuthScreen.signIn, email);
          },
        ),
        FlatButton(
          child: Text(widget.phrases[FauiPhrases.CreateAccountLink] ??
              'Create Account'),
          onPressed: () {
            this.switchScreen(AuthScreen.createAccount, email);
          },
        ),
      ],
    );
  }
}
