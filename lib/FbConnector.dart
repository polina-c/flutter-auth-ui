import 'dart:collection';
import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'FauiUtil.dart';
import 'FbException.dart';
import 'faui_model.dart';

var uuid = Uuid();

// https://firebase.google.com/docs/reference/rest/auth
class FbConnector {
  static Future<void> DeleteUserIfExists({
    @required String apiKey,
    @required String idToken,
  }) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: idToken, name: "idToken");

    await _SendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.DeleteAccount,
      params: {
        "idToken": idToken,
      },
      acceptableErrors: HashSet.from({FbException.UserNotFoundCode}),
    );
  }

  static Future<void> SendResetLink({
    @required String apiKey,
    @required String email,
  }) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: email, name: "email");
    await _SendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.SendResetLink,
      params: {
        "email": email,
        "requestType": "PASSWORD_RESET",
      },
    );
  }

  static Future RegisterUser(
      {@required String apiKey,
      @required String email,
      String password}) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: email, name: "email");

    await _SendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.RegisterUser,
      params: {
        "email": email,
        "password": password ?? uuid.v4(),
      },
    );

    await SendResetLink(apiKey: apiKey, email: email);
  }

  static Future<FauiUser> SignInUser({
    @required String apiKey,
    @required String email,
    @required String password,
  }) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: email, name: "email");
    FauiUtil.ThrowIfNullOrEmpty(value: password, name: "password");

    Map<String, dynamic> response = await _SendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.SignIn,
      params: {
        "email": email,
        "password": password,
        "returnSecureToken": true,
      },
    );

    FauiUser user = FbResponseToUser(response);

    if (user.email == null)
      throw Exception(
          "Email is not expected to be null in Firebase response for sign in");
    if (user.userId == null)
      throw Exception(
          "UserId is not expected to be null in Firebase response for sign in");

    return user;
  }

  static Future<FauiUser> VerifyToken({
    @required String apiKey,
    @required String token,
  }) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: token, name: "token");

    Map<String, dynamic> response = await _SendFbApiRequest(
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

  static FauiUser FbResponseToUser(Map<String, dynamic> response) {
    String idToken = response['idToken'] ?? response['id_token'];

    Map<String, dynamic> parsedToken = FauiUtil.ParseJwt(idToken);

    var user = FauiUser(
      email: response['email'] ?? parsedToken['email'],
      userId: parsedToken["userId"] ?? parsedToken["user_id"],
      token: idToken,
      refreshToken: response['refreshToken'] ?? response['refresh_token'],
    );

    return user;
  }

  static Future<Map<String, dynamic>> _SendFbApiRequest({
    @required String apiKey,
    @required String action,
    @required Map<String, dynamic> params,
    HashSet<String> acceptableErrors,
  }) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: action, name: "action");

    Response response = await post(
      "https://identitytoolkit.googleapis.com/v1/accounts:${action}?key=$apiKey",
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
    ReportFailedRequest(action, response);
    return null;
  }

  static Future<FauiUser> RefreshToken(
      {@required FauiUser user, @required String apiKey}) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: user.refreshToken, name: "apiKey");

    Response response = await post(
      "https://securetoken.googleapis.com/v1/token?key=$apiKey",
      body: jsonEncode({
        "grant_type": "refresh_token",
        "refresh_token": user.refreshToken,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      ReportFailedRequest("refresh_token", response);
      return null;
    }

    user = FbResponseToUser(jsonDecode(response.body));

    return user;
  }

  static void ReportFailedRequest(String action, dynamic response) {
    String message = "Error requesting firebase api $action.";
    print(message);
    PrintResponse(response);
    throw FbException(message + response.body);
  }

  static void PrintResponse(dynamic response) {
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
