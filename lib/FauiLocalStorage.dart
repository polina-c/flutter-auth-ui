import 'dart:convert';
import 'dart:html';
import 'FauiAuthState.dart';
import 'FauiUtil.dart';
import 'faui_model.dart';
import 'package:http/http.dart';

import 'FbConnector.dart';
import 'package:meta/meta.dart';

class FauiLocalStorage {
  static void SaveUserLocallyForSilentSignIn() {
    _StoreLocally(_LocalKey, jsonEncode(FauiAuthState.User));
    print("ssi: saved locally");
  }

  static void DeleteUserLocally() {
    _DeleteLocally(_LocalKey);
    print("ssi: deleted locally");
  }

  static Future TrySignInSilently(String apiKey) async {
    print("ssi: started silent sign-in");
    try {
      FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
      String v = _GetLocalValue(_LocalKey);
      if (v == null || v == "null") {
        print("ssi: no user stored");
        return;
      }

      FauiUser user = FauiUser.fromJson(jsonDecode(v));
      if (user == null || user.refreshToken == null) {
        print("ssi: no refresh token found");
        return;
      }
      user = await FbConnector.RefreshToken(user: user, apiKey: apiKey);
      _StoreLocally(_LocalKey, jsonEncode(user));
      FauiAuthState.User = user;
      print("ssi: succeeded silent sign-in");
      return;
    } catch (ex) {
      print("ssi: error during silent sign-in:");
      print(ex.toString());
      return;
    }
  }

  static const _LocalKey = "user";

  static void _DeleteLocally(String key) {
    window.localStorage.remove(key);
  }

  static String _GetLocalValue(String key) {
    return window.localStorage[key];
  }

  static void _StoreLocally(String key, String value) {
    window.localStorage[key] = value;
  }
}
