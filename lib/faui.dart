library faui;

import 'package:flutter/material.dart';

import 'src/10_auth/auth_state.dart';
import 'src/10_auth/local_storage.dart';
import 'src/10_auth/auth_screen.dart';
import 'src/90_model/faui_phrases.dart';
import 'src/90_model/faui_user.dart';

export 'src/90_model/faui_user.dart';
export 'src/90_model/faui_db.dart';
export 'src/90_model/faui_phrases.dart';
export 'src/10_data/faui_db_access.dart';
export 'src/10_auth/auth_connector.dart';

/// Returns the signed-in user or null
FauiUser get fauiUser {
  return FauiAuthState.user;
}

/// Sets currently signed-in user
set fauiUser(FauiUser v) {
  FauiAuthState.user = v;
}

/// Signs out the user
void fauiSignOut() {
  FauiAuthState.user = null;
  FauiLocalStorage.deleteUserLocally();
}

/// Saves user locally to enable silent sign-in
void fauiSaveUserLocallyForSilentSignIn() {
  FauiLocalStorage.saveUserLocallyForSilentSignIn();
}

/// Tries to sign-in silently
Future fauiTrySignInSilently({
  String firebaseApiKey,
}) async {
  return await FauiLocalStorage.trySignInSilently(firebaseApiKey);
}

/// Builds sign-in dialog. If startWithRegistration is true, the dialog
/// first suggests user to create account with option to sign-in, otherwize
/// it suggests user to sign-in with option to create account.
Widget fauiBuildAuthScreen(
  VoidCallback onExit,
  String firebaseApiKey, {
  bool startWithRegistration = false,
}) {
  return FauiAuthScreen(
    onExit,
    firebaseApiKey,
    startWithRegistration,
  );
}

/// Builds custom sign-in dialog. If startWithRegistration is true, the dialog
/// first suggests user to create account with option to sign-in, otherwize
/// it suggests user to sign-in with option to create account.
Widget fauiBuildCustomAuthScreen(
    VoidCallback onExit,
    String firebaseApiKey,
    Map<FauiPhrases, String> phrases,
    Widget builder(
  BuildContext context,
  String title,
  Widget content,
  VoidCallback close,
),
    {bool startWithRegistration = false}) {
  return FauiAuthScreen.custom(
    onExit,
    firebaseApiKey,
    builder,
    phrases,
    startWithRegistration,
  );
}
