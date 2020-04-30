import 'package:flutter/material.dart';

class AuthProgress extends StatelessWidget {
  final String Phrase;

  AuthProgress(this.Phrase);

 String displayMessage(String phrase) {
    switch (phrase) {
      case 'widget.phrases[FauiPhrases.CreatingAccountMessage]':
        return "creating account...";
      case 'widget.phrases[FauiPhrases.SigningInMessage]':
        return "signing in...";
      case 'widget.phrases[FauiPhrases.SendingPasswordResetLinkMessage]':
        return "sending password reset link...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.20,
        width: MediaQuery.of(context).size.width * 0.15,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(displayMessage(this.Phrase),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.normal,
                  )),
            ]));
  }
}