import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../90_infra/faui_error.dart';
import '../90_model/faui_phrases.dart';
import '../90_model/faui_user.dart';
import 'auth_connector.dart';
import 'auth_progress.dart';
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

enum _AuthScreen {
  signIn,
  createAccount,
  forgotPassword,
  verifyEmail,
  resetPassword,
}

class _FauiAuthScreenState extends State<FauiAuthScreen> {
  _AuthScreen _authScreen = _AuthScreen.signIn;
  String _error;
  String _email;
  bool _onExitInvoked = false;
  bool _loading = false;
  FocusNode _focusNodeCurrent;
  FocusNode _emailNode = FocusNode();
  FocusNode _passwordNode = FocusNode();
  final TextEditingController _emailcontroller = new TextEditingController();
  final TextEditingController _passwordcontroller = new TextEditingController();

  @override
  void initState() {
    super.initState();

    if (this.widget.startWithRegistration) {
      this._authScreen = _AuthScreen.createAccount;
    }
  }

  void switchScreen(_AuthScreen authScreen, String email) {
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

  String resolvePhrase(FauiPhrases phrase, String message) {
    return widget.phrases[phrase] ?? message;
  }

  @override
  void dispose() {
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    // This check takes care of "setState() called after dispose()" exception.
    // This exception is raised because when Enter key is pressed, it calls submit().
    // This causes the Future to complete after the widget has already been disposed.
    // More details can be found at the link:
    // "https://github.com/Norbert515/flutter_villains/issues/8".
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_focusNodeCurrent != null) {
      FocusScope.of(context).requestFocus(_focusNodeCurrent);
      _focusNodeCurrent = null;
    }
    return this.widget.builder(
        context, _getScreenTitle(), _getScreen(context), this.widget.onExit);
  }

  String _getScreenTitle() {
    switch (this._authScreen) {
      case _AuthScreen.signIn:
        return resolvePhrase(FauiPhrases.SignInTitle, 'Sign In');
      case _AuthScreen.createAccount:
        return resolvePhrase(FauiPhrases.CreateAccountTitle, 'Create Account');
      case _AuthScreen.forgotPassword:
        return resolvePhrase(FauiPhrases.ForgotPassordTitle, 'Forgot Password');
      case _AuthScreen.verifyEmail:
        return resolvePhrase(FauiPhrases.VerifyEmailTitle, 'Verify Email');
      case _AuthScreen.resetPassword:
        return resolvePhrase(FauiPhrases.ResetPasswordTitle, 'Reset Password');
      default:
        throw "Unexpected screen $_authScreen";
    }
  }

  Widget _getScreen(BuildContext context) {
    switch (this._authScreen) {
      case _AuthScreen.signIn:
        return _buildSignInScreen(context);
      case _AuthScreen.createAccount:
        return _buildCreateAccountScreen(context);
      case _AuthScreen.forgotPassword:
        return _buildForgotPasswordScreen(context, this._email);
      case _AuthScreen.verifyEmail:
        return _buildVerifyEmailScreen(context, this._email);
      case _AuthScreen.resetPassword:
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

  _changeFocus(FocusNode current, FocusNode next) {
    // https://stackoverflow.com/questions/56221653/focusnode-why-is-requestfocus-not-working/57104572#57104572
    current?.unfocus();
    setState(() => _focusNodeCurrent = next);
  }

  Widget _buildTextBox(
      TextEditingController controller,
      bool hideFieldValue,
      FocusNode currentNode,
      FocusNode nextNode,
      String fieldName,
      Future<Widget> Function() submit) {
    handleKey(RawKeyEvent key) {
      if (key is! RawKeyDownEvent) {
        return;
      }
      setState(() => _error = "");
      if (key.physicalKey.debugName == 'Enter') {
        submit();
      }
      if ((key.logicalKey.debugName == 'Tab') && (nextNode != null)) {
        _changeFocus(currentNode, nextNode);
      }
    }

    return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (key) => handleKey(key),
        child: TextFormField(
          focusNode: currentNode,
          obscureText: hideFieldValue,
          controller: controller,
          autofocus: true,
          onEditingComplete: () => {},
          // it is important to have this handler to catch 'Enter'
          decoration: InputDecoration(
            labelText: fieldName,
          ),
        ));
  }

  Widget _buildCreateAccountScreen(BuildContext context) {
    final submit = () async {
      try {
        setState(() {
          _loading = true;
        });
        await fauiRegisterUser(
          apiKey: this.widget.firebaseApiKey,
          email: _emailcontroller.text,
        );
        setState(() {
          _loading = false;
        });

        this.switchScreen(_AuthScreen.verifyEmail, _emailcontroller.text);
      } catch (e) {
        this.setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = _emailcontroller.text;
          _loading = false;
        });
      }
    };

    return Column(children: <Widget>[
      _buildTextBox(_emailcontroller, false, _emailNode, null,
          resolvePhrase(FauiPhrases.EmailTextField, 'Email'), submit),
      _buildError(context, _error),
      if (_loading == true)
        AuthProgress(resolvePhrase(
            FauiPhrases.CreatingAccountMessage, 'creating account...')),
      if (_loading == false)
        RaisedButton(
          child: Text(
              resolvePhrase(FauiPhrases.CreateAccountButton, 'Create Account')),
          onPressed: submit,
        ),
      if (_loading == false)
        FlatButton(
            child: Text(resolvePhrase(
                FauiPhrases.HaveAccountLink, 'Have account? Sign in.')),
            onPressed: () {
              this.switchScreen(_AuthScreen.signIn, _emailcontroller.text);
            }),
    ]);
  }

  Widget _buildSignInScreen(BuildContext context) {
    final submit = () async {
      try {
        setState(() {
          _loading = true;
        });
        FauiUser user = await fauiSignInUser(
          apiKey: this.widget.firebaseApiKey,
          email: _emailcontroller.text,
          password: _passwordcontroller.text,
        );
        setState(() {
          _loading = false;
        });
        this.afterAuthorized(context, user);
      } catch (e) {
        this.setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = _emailcontroller.text;
          _loading = false;
        });
      }
    };

    return Column(children: <Widget>[
      _buildTextBox(_emailcontroller, false, _emailNode, _passwordNode,
          resolvePhrase(FauiPhrases.EmailTextField, 'Email'), submit),
      _buildTextBox(_passwordcontroller, true, _passwordNode, null,
          resolvePhrase(FauiPhrases.PasswordTextField, 'Password'), submit),
      _buildError(context, _error),
      if (_loading == true)
        AuthProgress(
            resolvePhrase(FauiPhrases.SigningInMessage, 'signing in...')),
      if (_loading == false)
        RaisedButton(
          child: Text(resolvePhrase(FauiPhrases.SignInButton, 'Sign In')),
          onPressed: submit,
        ),
      if (_loading == false)
        FlatButton(
          child: Text(
              resolvePhrase(FauiPhrases.CreateAccountLink, 'Create Account')),
          onPressed: () {
            this.switchScreen(_AuthScreen.createAccount, _emailcontroller.text);
          },
        ),
      if (_loading == false)
        FlatButton(
          child: Text(
              resolvePhrase(FauiPhrases.ForgotPassordLink, 'Forgot Password?')),
          onPressed: () {
            this.switchScreen(
                _AuthScreen.forgotPassword, _emailcontroller.text);
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
          resolvePhrase(FauiPhrases.WeSentVerificationEmailMessage,
              "We sent verification link to $email"),
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: Text(resolvePhrase(FauiPhrases.SignInButton, 'Sign In')),
          onPressed: () {
            this.switchScreen(_AuthScreen.signIn, email);
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
          resolvePhrase(FauiPhrases.WeSentLinkToResetPasswordMEssage,
              "We sent the link to reset your password to $email"),
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: Text(resolvePhrase(FauiPhrases.SignInButton, 'Sign In')),
          onPressed: () {
            this.switchScreen(_AuthScreen.signIn, email);
          },
        ),
      ],
    );
  }

  Widget _buildForgotPasswordScreen(BuildContext context, String email) {
    final submit = () async {
      try {
        setState(() {
          _loading = true;
        });
        await fauiSendResetLink(
          apiKey: this.widget.firebaseApiKey,
          email: _emailcontroller.text,
        );
        setState(() {
          _loading = false;
        });
        this.switchScreen(_AuthScreen.resetPassword, _emailcontroller.text);
      } catch (e) {
        this.setState(() {
          this._error = FauiError.exceptionToUiMessage(e);
          this._email = _emailcontroller.text;
          _loading = false;
        });
      }
    };

    return Column(
      children: <Widget>[
        _buildTextBox(_emailcontroller, false, _emailNode, null,
            resolvePhrase(FauiPhrases.EmailTextField, 'Email'), submit),
        _buildError(context, _error),
        if (_loading == true)
          AuthProgress(resolvePhrase(
              FauiPhrases.SendingPasswordResetLinkMessage,
              'sending password reset link...')),
        if (_loading == false)
          RaisedButton(
            child: Text(resolvePhrase(FauiPhrases.SendPasswordResetLinkButton,
                'Send Password Reset Link')),
            onPressed: submit,
          ),
        if (_loading == false)
          FlatButton(
            child: Text(resolvePhrase(FauiPhrases.SignInLink, 'Sign In')),
            onPressed: () {
              this.switchScreen(_AuthScreen.signIn, email);
            },
          ),
        if (_loading == false)
          FlatButton(
            child: Text(
                resolvePhrase(FauiPhrases.CreateAccountLink, 'Create Account')),
            onPressed: () {
              this.switchScreen(_AuthScreen.createAccount, email);
            },
          ),
      ],
    );
  }
}
