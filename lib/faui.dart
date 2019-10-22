import 'package:faui/FauiPhrases.dart';
import 'package:faui/src/FauiAuthScreen.dart';
import 'package:faui/src/FauiAuthState.dart';
import 'package:faui/src/FauiLocalStorage.dart';
import 'package:flutter/material.dart';

import 'FauiUser.dart';

///Facade class for the library 'faui'
class Faui {
  /// Returns the signed-in user or null
  static FauiUser get user {
    return FauiAuthState.user;
  }

  /// Sets currently signed-in user
  static set user(FauiUser v) {
    FauiAuthState.user = v;
  }

  /// Signes out the user
  static void signOut() {
    FauiAuthState.user = null;
    FauiLocalStorage.deleteUserLocally();
  }

  /// Saves user locally to enable silent sign-in
  static void saveUserLocallyForSilentSignIn() {
    FauiLocalStorage.saveUserLocallyForSilentSignIn();
  }

  /// Tries to sign-in silently
  static Future trySignInSilently({
    @required String firebaseApiKey,
  }) async {
    return await FauiLocalStorage.trySignInSilently(firebaseApiKey);
  }

  /// Builds sign-in dialog. If startWithRegistration is true, the dialog
  /// first suggests user to create account with option to sign-in, otherwize
  /// it suggests user to sign-in with option to create account.
  static Widget buildAuthScreen(
      {@required VoidCallback onExit,
      @required String firebaseApiKey,
      bool startWithRegistration = false}) {
    return FauiAuthScreen(
      onExit: onExit,
      firebaseApiKey: firebaseApiKey,
      startWithRegistration: startWithRegistration,
    );
  }

  /// Builds custome sign-in dialog. If startWithRegistration is true, the dialog
  /// first suggests user to create account with option to sign-in, otherwize
  /// it suggests user to sign-in with option to create account.
  static Widget buildCustomAuthScreen(
      {@required
          VoidCallback onExit,
      @required
          String firebaseApiKey,
      @required
          Map<FauiPhrases, String> phrases,
      @required
          Widget builder(
        BuildContext context,
        String title,
        Widget content,
        VoidCallback close,
      ),
      bool startWithRegistration = false}) {
    return FauiAuthScreen.custom(
      onExit: onExit,
      firebaseApiKey: firebaseApiKey,
      startWithRegistration: startWithRegistration,
      builder: builder,
    );
  }
}
