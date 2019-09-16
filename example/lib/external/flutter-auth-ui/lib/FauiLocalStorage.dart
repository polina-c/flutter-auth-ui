import 'dart:convert';
import 'FauiAuthState.dart';
import 'FauiUtil.dart';
import 'faui_model.dart';

import 'FbConnector.dart';

import 'package:crypted_preferences/crypted_preferences.dart';

class FauiLocalStorage {
  static Preferences _prefs;
  static const String _LocalKey = "user";

  static void _ThowIfNotInitialized() {
    if (_prefs == null)
      throw "To use local storage call faui.TrySignInSilently() before app start in order to initialize local storage.";
  }

  static Future _Initialize() async {
    try {
      _prefs = await Preferences.preferences(path: 'pathToPrefs');
    } catch (ex) {
      print('error initializing:');
      print(ex);
    }
  }

  static void SaveUserLocallyForSilentSignIn() {
    _StoreLocally(_LocalKey, jsonEncode(FauiAuthState.User));
    print("sso: saved locally");
  }

  static void DeleteUserLocally() {
    _DeleteLocally(_LocalKey);
    print("sso: deleted locally");
  }

  static Future TrySignInSilently(String apiKey) async {
    print("sso: started silent sign-in");
    try {
      await _Initialize();
      FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
      String v = _GetLocalValue(_LocalKey);
      if (v == null || v == "null") {
        print("sso: no user stored");
        return;
      }

      FauiUser user = FauiUser.fromJson(jsonDecode(v));
      if (user == null || user.refreshToken == null) {
        print("sso: no refresh token found");
        return;
      }
      user = await FbConnector.RefreshToken(user: user, apiKey: apiKey);
      _StoreLocally(_LocalKey, jsonEncode(user));
      FauiAuthState.User = user;
      print("sso: succeeded silent sign-in");
      return;
    } catch (ex) {
      print("sso: error during silent sign-in:");
      print(ex.toString());
      return;
    }
  }

  static void _DeleteLocally(String key) {
    _ThowIfNotInitialized();
    _prefs.remove(key);
  }

  static String _GetLocalValue(String key) {
    _ThowIfNotInitialized();
    return _prefs.getString(key);
  }

  static void _StoreLocally(String key, String value) {
    _ThowIfNotInitialized();
    _prefs.setString(key, value);
  }
}
