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
  bool _loading = false;

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

  String resolvePhrase(FauiPhrases phrase,String message) {
    return widget.phrases[phrase] ?? message;
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.builder(
        context, _getScreenTitle(), _getScreen(context), this.widget.onExit);
  }

  String _getScreenTitle() {
    switch (this._authScreen) {
      case AuthScreen.signIn:
        return resolvePhrase(FauiPhrases.SignInTitle,'Sign In');
      case AuthScreen.createAccount:
        return resolvePhrase(FauiPhrases.CreateAccountTitle,'Create Account');
      case AuthScreen.forgotPassword:
        return resolvePhrase(FauiPhrases.ForgotPassordTitle,'Forgot Password');
      case AuthScreen.verifyEmail:
        return resolvePhrase(FauiPhrases.VerifyEmailTitle,'Verify Email');
      case AuthScreen.resetPassword:
        return resolvePhrase(FauiPhrases.ResetPasswordTitle,'Reset Password');
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
        setState(() {
          _loading = true;
        });
        await fauiRegisterUser(
          apiKey: this.widget.firebaseApiKey,
          email: emailController.text,
        );
        setState(() {
          _loading = false;
        });

        this.switchScreen(AuthScreen.verifyEmail, emailController.text);
      } catch (e) {
        this.setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = emailController.text;
          _loading = false;
        });
      }
    };

    return Column(children: <Widget>[
      Focus(
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: resolvePhrase(FauiPhrases.EmailTextField,"EMail"),
            ),
            onSubmitted: (s) {
              submit();
            },
          ),
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              if (this._error?.isNotEmpty ?? true) {
                setState(() {
                  this._error = "";
                });
              }}
          }),
      _buildError(context, _error),
      (_loading == true) ? AuthProgress(resolvePhrase(FauiPhrases.CreatingAccountMessage,'creating account...')) : RaisedButton(
        child: Text(resolvePhrase(FauiPhrases.CreateAccountButton,'Create Account')),
        onPressed: submit,
      ),
      if (_loading == false) FlatButton(
        child: Text(resolvePhrase(FauiPhrases.HaveAccountLink,'Have account? Sign in.')),
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
        setState(() {
          _loading = true;
        });
        FauiUser user = await fauiSignInUser(
          apiKey: this.widget.firebaseApiKey,
          email: emailController.text,
          password: passwordController.text,
        );
        setState(() {
          _loading = false;
        });
        this.afterAuthorized(context, user);
      } catch (e) {
        this.setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = emailController.text;
          _loading = false;
        });
      }
    };

    return Column(
        children: <Widget>[
          TextField(
            controller: emailController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: resolvePhrase(FauiPhrases.EmailTextField,"EMail"),
            ),
            onSubmitted: (s) {
              submit();
            },
          ),
          Focus(
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText:
                  resolvePhrase(FauiPhrases.PasswordTextField,"Password"),
                ),
                onSubmitted: (s) {
                  submit();
                },
              ),
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  if ((this._error?.isNotEmpty ?? true) && (this._email.isNotEmpty)) {
                    setState(() {
                      this._error = "";
                    });
                  }}
              }),
          _buildError(context, _error),

          (_loading == true) ? AuthProgress(resolvePhrase(FauiPhrases.SigningInMessage,'signing in...')) : RaisedButton(
            child: Text(resolvePhrase(FauiPhrases.SignInButton,'Sign In')),
            onPressed: submit,
          ),
          if (_loading == false) FlatButton(
            child: Text(resolvePhrase(FauiPhrases.CreateAccountLink,'Create Account')),
            onPressed: () {
              this.switchScreen(AuthScreen.createAccount, emailController.text);
            },
          ),
          if (_loading == false) FlatButton(
            child: Text(resolvePhrase(FauiPhrases.ForgotPassordLink,'Forgot Password?')),
            onPressed: () {
              this.switchScreen(AuthScreen.forgotPassword, emailController.text);
            },
          ),
        ]);
  }

  Widget _buildVerifyEmailScreen(BuildContext context, String email) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          resolvePhrase(FauiPhrases.WeSentVerificationEmailMessage,"We sent verification link to $email"),
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: Text(resolvePhrase(FauiPhrases.SignInButton,'Sign In')),
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
          resolvePhrase(FauiPhrases.WeSentLinkToResetPasswordMEssage,"We sent the link to reset your password to $email"),
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: Text(resolvePhrase(FauiPhrases.SignInButton,'Sign In')),
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
        setState(() {
          _loading = true;
        });
        await fauiSendResetLink(
          apiKey: this.widget.firebaseApiKey,
          email: emailController.text,
        );
        setState(() {
          _loading = false;
        });
        this.switchScreen(AuthScreen.resetPassword, emailController.text);
      } catch (e) {
        this.setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = emailController.text;
          _loading = false;
        });
      }
    };

    return Column(
      children: <Widget>[
        Focus(
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: resolvePhrase(FauiPhrases.EmailTextField,"EMail"),
              ),
              onSubmitted: (s) {
                submit();
              },
            ),
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                if (this._error?.isNotEmpty ?? true) {
                  setState(() {
                    this._error = "";
                  });
                }}
            }),
        _buildError(context, _error),
        (_loading == true) ? AuthProgress(resolvePhrase(FauiPhrases.SendingPasswordResetLinkMessage,'sending password reset link...')) : RaisedButton(
          child: Text(resolvePhrase(FauiPhrases.SendPasswordResetLinkButton,'Send Password Reset Link')),
          onPressed: submit,
        ),
        if (_loading == false) FlatButton(
          child: Text(resolvePhrase(FauiPhrases.SignInLink,'Sign In')),
          onPressed: () {
            this.switchScreen(AuthScreen.signIn, email);
          },
        ),
        if (_loading == false) FlatButton(
          child: Text(resolvePhrase(FauiPhrases.CreateAccountLink,'Create Account')),
          onPressed: () {
            this.switchScreen(AuthScreen.createAccount, email);
          },
        ),
      ],
    );
  }
}