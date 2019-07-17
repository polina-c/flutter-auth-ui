import 'package:flutter_web/material.dart';

import 'FauiAuthScreen.dart';
import 'FauiAuthState.dart';
import 'faui_model.dart';

class faui {
  static FauiUser get User {
    FauiUser user = FauiAuthState.User;
    return user;
  }

  static void SignOut() {
    FauiAuthState.User = null;
  }

  static Widget BuildAuthScreen({
    @required VoidCallback onSuccess,
    @required VoidCallback onCancel,
    @required String firebaseApiKey,
  }) {
    return FauiAuthScreen(
      onSuccess: onSuccess,
      onCancel: onCancel,
      firebaseApiKey: firebaseApiKey,
    );
  }
}
