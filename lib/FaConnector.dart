import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'FaUtil.dart';
import 'flutter_auth_model.dart';

// https://firebase.google.com/docs/reference/rest/auth

class FaConnector {
  static Future<void> deleteUserIfExists({
    @required String apiKey,
    @required String idToken,
  }) async {
    FaUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FaUtil.ThrowIfNullOrEmpty(value: idToken, name: "idToken");

    await _sendFbApiRequest(
        apiKey: apiKey,
        action: "deleteAccount",
        params: {
          "idToken": idToken,
        },
        acceptableErrors: HashSet.from({"USER_NOT_FOUND"}));
  }

  static Future<void> sendResetLink({
    @required String apiKey,
    @required String email,
  }) async {
    FaUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FaUtil.ThrowIfNullOrEmpty(value: email, name: "email");
    _sendFbApiRequest(
      apiKey: apiKey,
      action: "getOobConfirmationCode",
      params: {
        "email": email,
        "requestType": "PASSWORD_RESET",
      },
    );
  }

  static Future<FaUser> registerUser({
    @required String apiKey,
    @required String email,
    @required String password,
  }) async {
    return await _registerOrSignIn(
      apiKey: apiKey,
      email: email,
      password: password,
      action: 'signupNewUser',
      actionDisplayName: 'register user',
    );
  }

  static Future<FaUser> signInUser({
    @required String apiKey,
    @required String email,
    @required String password,
  }) async {
    return await _registerOrSignIn(
      apiKey: apiKey,
      email: email,
      password: password,
      action: 'verifyPassword',
      actionDisplayName: 'sign in user',
    );
  }

  static Future<FaUser> _registerOrSignIn({
    @required String apiKey,
    @required String email,
    @required String password,
    @required String action,
    @required String actionDisplayName,
  }) async {
    FaUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FaUtil.ThrowIfNullOrEmpty(value: email, name: "email");
    FaUtil.ThrowIfNullOrEmpty(value: password, name: "password");

    var result = await _sendFbApiRequest(
      apiKey: apiKey,
      action: action,
      params: {
        "email": email,
        "password": password,
        "requestType": "PASSWORD_RESET",
      },
    );

    return FaUser.fromJson(result);
  }

  static dynamic _sendFbApiRequest({
    @required String apiKey,
    @required String action,
    @required Map<String, dynamic> params,
    HashSet<String> acceptableErrors,
  }) async {
    FaUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FaUtil.ThrowIfNullOrEmpty(value: action, name: "action");

    Response response = await post(
      "https://www.googleapis.com/identitytoolkit/v3/relyingparty/${action}?key=$apiKey",
      body: jsonEncode(params),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    if (acceptableErrors != null) {
      for (String error in acceptableErrors) {
        if (response.body.contains(error)) {
          return null;
        }
      }
    }

    String message = "Error requesting firebase api $action.";
    print(message);
    print("code: " + response.statusCode.toString());
    print("response body: " + response.body);
    print("reason: " + response.reasonPhrase);
    throw Exception(message + response.body);
  }
}
