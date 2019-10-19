import 'dart:convert';
import '../FauiUser.dart';
import '../FbConnector.dart';
import 'FauiAuthState.dart';
import 'FauiUtil.dart';

import 'package:crypted_preferences/crypted_preferences.dart';

class FauiLocalStorage {
  static Preferences _prefs;
  static const String _LocalKey = "user";

  static void _thowIfNotInitialized() {
    if (_prefs == null)
      throw "To use local storage call faui.TrySignInSilently() before app start in order to initialize local storage.";
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
      FauiUtil.throwIfNullOrEmpty(value: apiKey, name: "apiKey");
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
      user = await FbConnector.refreshToken(user: user, apiKey: apiKey);
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
