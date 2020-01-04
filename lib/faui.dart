import 'package:faui/src/90_model/faui_phrases.dart';
import 'package:faui/src/05_db/db.dart';
import 'package:faui/src/05_db/db_connector.dart';
import 'package:faui/src/06_auth/auth_screen.dart';
import 'package:faui/src/06_auth/auth_state.dart';
import 'package:faui/src/06_auth/local_storage.dart';
import 'package:flutter/material.dart';

import 'package:faui/src/90_model/faui_user.dart';

/// Returns the signed-in user or null
FauiUser get fauiUser {
  return FauiAuthState.user;
}

/// Sets currently signed-in user
set fauiUser(FauiUser v) {
  FauiAuthState.user = v;
}

/// Signes out the user
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
    {VoidCallback onExit,
    String firebaseApiKey,
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
Widget fauiBuildCustomAuthScreen(
    {@required
        VoidCallback onExit,
    @required
        String firebaseApiKey,
    @required
        Map<FauiPhrases, String> phrases,
    @required
        Widget builder({
      BuildContext context,
      String title,
      Widget content,
      VoidCallback close,
    }),
    bool startWithRegistration = false}) {
  return FauiAuthScreen.custom(
    onExit: onExit,
    firebaseApiKey: firebaseApiKey,
    startWithRegistration: startWithRegistration,
    phrases: phrases,
    builder: builder,
  );
}

Future<void> saveDoc({
  FauiDb db,
  FauiUser user,
  String docId,
  Map<String, dynamic> content,
}) async {
//  await DbAccess.save(
//    db: db,
//    docId: docId,
//    key: key,
//    value: value,
//    user: user,
//  );
}

Future<Map<String, dynamic>> loadDoc({
  FauiDb db,
  String docId,
  String key,
  FauiUser user,
}) async {
//  await DbAccess.load(
//    db: db,
//    docId: docId,
//    key: key,
//    user: user,
//  );
}
