import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../90_model/faui_user.dart';

import 'auth_connector.dart';
import 'auth_state.dart';

class FauiLocalStorage {
  static const String _LocalKey = "user";

  static void saveUserLocallyForSilentSignIn() {
    _storeLocally(_LocalKey, jsonEncode(FauiAuthState.user));
    print("sso: saved locally");
  }

  static void deleteUserLocally() {
    _deleteLocally(_LocalKey);
    print("sso: deleted locally");
  }

  static trySignInSilently(String apiKey) async {
    print("sso: started silent sign-in");
    try {
      String v = await _getLocalValue(_LocalKey);
      if (v == null || v == "null") {
        print("sso: no user stored");
        return;
      }

      FauiUser user = FauiUser.fromJson(jsonDecode(v));
      if (user == null || user.refreshToken == null) {
        print("sso: no refresh token found");
        return;
      }
      user = await fauiRefreshToken(user: user, apiKey: apiKey);
      _storeLocally(_LocalKey, jsonEncode(user));
      FauiAuthState.user = user;
      print("sso: succeeded silent sign-in");
      return;
    } catch (ex) {
      print("sso: error during silent sign-in:");
      print(ex.toString());
      return;
    }
  }

  static _deleteLocally(String key) async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      prefs.remove(key);
    } catch (ex) {
      print("sso: Error deleting from SharedPreferences Instance");
    }
  }

  static Future<String> _getLocalValue(String key) async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (ex) {
      print("sso: Error retrieving from SharedPreferences Instance : " + ex);
      return null;
    }
  }

  static _storeLocally(String key, String value) async {
    SharedPreferences prefs;
    try {
      if (key == null) throw ("sso: Error - Key is null");
      if (value == null) throw ("sso: Error - User Value is null");
      prefs = await SharedPreferences.getInstance();
      if (prefs == null)
        throw ("sso: Error - Cannot retrieve Shared Preferences Instance");
      prefs.setString(key, value);
      if (prefs.getString(key) != value)
        throw ("sso: Error - Unable to verify data stored correctly");
    } catch (ex) {
      print(ex);
    }
  }
}
