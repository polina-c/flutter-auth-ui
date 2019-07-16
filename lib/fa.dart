import 'package:flutter_web/material.dart';

import 'FaAuthScreen.dart';
import 'FaAuthState.dart';
import 'fa_model.dart';

class fa {
  static FaUser get User {
    FaUser user = FaAuthState.User;
    return user;
  }

  static void SignOut() {
    FaAuthState.User = null;
  }

  static Widget BuildAuthScreen({
    @required VoidCallback onSuccess,
    @required VoidCallback onCancel,
    @required String firebaseApiKey,
  }) {
    return FaAuthScreen(
      onSuccess: onSuccess,
      onCancel: onCancel,
      firebaseApiKey: firebaseApiKey,
    );
  }
}
