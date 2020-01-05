import 'dart:convert';
import '../90_infra/faui_exception.dart';
import '../90_model/faui_user.dart';

import 'package:crypted_preferences/crypted_preferences.dart';

import 'auth_connector.dart';
import 'auth_state.dart';

class FauiLocalStorage {
  static Preferences _prefs;
  static const String _LocalKey = "user";

  static void _thowIfNotInitialized() {
    if (_prefs == null)
      throw "To use local storage call fauiTrySignInSilently() before app start in order to initialize local storage.";
  }

  static Future _initialize() async {
    try {
      _prefs = await Preferences.preferences(path: 'pathToPrefs');
    } catch (ex) {
      print('error initializing:');
      print(ex);
    }
  }

  static void saveUserLocallyForSilentSignIn() {
    _storeLocally(_LocalKey, jsonEncode(FauiAuthState.user));
    print("sso: saved locally");
  }

  static void deleteUserLocally() {
    _deleteLocally(_LocalKey);
    print("sso: deleted locally");
  }

  static Future trySignInSilently(String apiKey) async {
    print("sso: started silent sign-in");
    try {
      await _initialize();
      throwIfEmpty(apiKey, "apiKey", FauiFailures.arg);
      String v = _getLocalValue(_LocalKey);
      if (v == null || v == "null") {
        print("sso: no user stored");
        return;
      }

      FauiUser user = FauiUser.fromJson(jsonDecode(v));
      if (user == null || user.refreshToken == null) {
        print("sso: no refresh token found");
        return;
      }
      user = await AuthConnector.refreshToken(user: user, apiKey: apiKey);
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

  static void _deleteLocally(String key) {
    _thowIfNotInitialized();
    _prefs.remove(key);
  }

  static String _getLocalValue(String key) {
    _thowIfNotInitialized();
    return _prefs.getString(key);
  }

  static void _storeLocally(String key, String value) {
    _thowIfNotInitialized();
    _prefs.setString(key, value);
  }
}
