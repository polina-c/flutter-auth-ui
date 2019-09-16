import 'dart:collection';
import 'dart:convert';
import 'dart:core';

import 'package:faui/FbException.dart';
import 'package:http/http.dart';

import 'package:faui/FauiUser.dart';
import 'package:uuid/uuid.dart';

import 'package:faui/FauiUtil.dart';

var uuid = Uuid();

// https://firebase.google.com/docs/reference/rest/auth

class FbConnector {
  static Future<void> deleteUserIfExists({
    String apiKey,
    String idToken,
  }) async {
    FauiUtil.throwIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.throwIfNullOrEmpty(value: idToken, name: "idToken");

    await _sendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.DeleteAccount,
      params: {
        "idToken": idToken,
      },
      acceptableErrors: HashSet.from({FbException.UserNotFoundCode}),
    );
  }

  static Future<void> sendResetLink({
    String apiKey,
    String email,
  }) async {
    FauiUtil.throwIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.throwIfNullOrEmpty(value: email, name: "email");
    await _sendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.SendResetLink,
      params: {
        "email": email,
        "requestType": "PASSWORD_RESET",
      },
    );
  }

  static Future registerUser(
      {String apiKey, String email, String password}) async {
    FauiUtil.throwIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.throwIfNullOrEmpty(value: email, name: "email");

    await _sendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.RegisterUser,
      params: {
        "email": email,
        "password": password ?? uuid.v4(),
      },
    );

    await sendResetLink(apiKey: apiKey, email: email);
  }

  static Future<FauiUser> signInUser({
    String apiKey,
    String email,
    String password,
  }) async {
    FauiUtil.throwIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.throwIfNullOrEmpty(value: email, name: "email");
    FauiUtil.throwIfNullOrEmpty(value: password, name: "password");

    Map<String, dynamic> response = await _sendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.SignIn,
      params: {
        "email": email,
        "password": password,
        "returnSecureToken": true,
      },
    );

    FauiUser user = fbResponseToUser(response);

    if (user.email == null)
      throw Exception(
          "Email is not expected to be null in Firebase response for sign in");
    if (user.userId == null)
      throw Exception(
          "UserId is not expected to be null in Firebase response for sign in");

    return user;
  }

  static Future<FauiUser> verifyToken({
    String apiKey,
    String token,
  }) async {
    FauiUtil.throwIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.throwIfNullOrEmpty(value: token, name: "token");

    Map<String, dynamic> response = await _sendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.Verify,
      params: {
        "idToken": token,
        "returnSecureToken": true,
      },
    );

    List<dynamic> users = response['users'];
    if (users == null || users.length != 1) {
      return null;
    }

    Map<String, dynamic> fbUser = users[0];

    FauiUser user = FauiUser(
      email: fbUser['email'],
      userId: fbUser["localId"],
      token: token,
      refreshToken: null,
    );

    return user;
  }

  static FauiUser fbResponseToUser(Map<String, dynamic> response) {
    String idToken = response['idToken'] ?? response['id_token'];

    Map<String, dynamic> parsedToken = FauiUtil.parseJwt(idToken);

    var user = FauiUser(
      email: response['email'] ?? parsedToken['email'],
      userId: parsedToken["userId"] ?? parsedToken["user_id"],
      token: idToken,
      refreshToken: response['refreshToken'] ?? response['refresh_token'],
    );

    return user;
  }

  static Future<Map<String, dynamic>> _sendFbApiRequest({
    String apiKey,
    String action,
    Map<String, dynamic> params,
    HashSet<String> acceptableErrors,
  }) async {
    FauiUtil.throwIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.throwIfNullOrEmpty(value: action, name: "action");

    Response response = await post(
      "https://identitytoolkit.googleapis.com/v1/accounts:$action?key=$apiKey",
      body: jsonEncode(params),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      return map;
    }

    if (acceptableErrors != null) {
      for (String error in acceptableErrors) {
        if (response.body.contains(error)) {
          return null;
        }
      }
    }
    reportFailedRequest(action, response);
    return null;
  }

  static Future<FauiUser> refreshToken({FauiUser user, String apiKey}) async {
    FauiUtil.throwIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.throwIfNullOrEmpty(value: user.refreshToken, name: "apiKey");

    Response response = await post(
      "https://securetoken.googleapis.com/v1/token?key=$apiKey",
      body: jsonEncode({
        "grant_type": "refresh_token",
        "refresh_token": user.refreshToken,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      reportFailedRequest("refresh_token", response);
      return null;
    }

    user = fbResponseToUser(jsonDecode(response.body));

    return user;
  }

  static void reportFailedRequest(String action, dynamic response) {
    String message = "Error requesting firebase api $action.";
    print(message);
    printResponse(response);
    throw FbException(message + response.body);
  }

  static void printResponse(dynamic response) {
    if (response is Response) {
      print("code: " + response.statusCode.toString());
      print("response body: " + response.body);
      print("reason: " + response.reasonPhrase);
      return;
    }
    print(
        "Could not print response of type ${response.runtimeType.toString()}");
  }
}

//https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:delete?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=[API_KEY]
class FirebaseActions {
  static const SendResetLink = "sendOobCode";
  static const DeleteAccount = "delete";
  static const RegisterUser = "signUp";
  static const SignIn = "signInWithPassword";
  static const Verify = "lookup";
}
