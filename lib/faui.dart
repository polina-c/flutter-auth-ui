import 'FauiAuthScreen.dart';
import 'FauiAuthState.dart';
import 'FauiLocalStorage.dart';
import 'FauiUser.dart';
import 'package:flutter/material.dart';

class Faui {
  static FauiUser get user {
    return FauiAuthState.user;
  }

  static set user(v) {
    FauiAuthState.user = v;
  }

  static void signOut() {
    FauiAuthState.user = null;
    FauiLocalStorage.deleteUserLocally();
  }

  static void saveUserLocallyForSilentSignIn() {
    FauiLocalStorage.saveUserLocallyForSilentSignIn();
  }

  static Future trySignInSilently({
    @required String firebaseApiKey,
  }) async {
    return await FauiLocalStorage.trySignInSilently(firebaseApiKey);
  }

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
}
