import 'FauiAuthScreen.dart';
import 'FauiAuthState.dart';
import 'FauiLocalStorage.dart';
import 'faui_model.dart';
import 'package:flutter/material.dart';

class faui {
  static FauiUser get User {
    return FauiAuthState.User;
  }

  static void set User(v) {
    FauiAuthState.User = v;
  }

  static void SignOut() {
    FauiAuthState.User = null;
    FauiLocalStorage.DeleteUserLocally();
  }

  static void SaveUserLocallyForSilentSignIn() {
    FauiLocalStorage.SaveUserLocallyForSilentSignIn();
  }

  static Future TrySignInSilently({
    @required String firebaseApiKey,
  }) async {
    return await FauiLocalStorage.TrySignInSilently(firebaseApiKey);
  }

  static Widget BuildAuthScreen(
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
