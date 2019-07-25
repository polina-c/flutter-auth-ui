import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'FauiUtil.dart';
import 'FbException.dart';
import 'faui_model.dart';

var uuid = Uuid();

// https://firebase.google.com/docs/reference/rest/auth
class FbConnector {
  static Future<void> deleteUserIfExists({
    @required String apiKey,
    @required String idToken,
  }) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: idToken, name: "idToken");

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
    @required String apiKey,
    @required String email,
  }) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: email, name: "email");
    _sendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.SendResetLink,
      params: {
        "email": email,
        "requestType": "PASSWORD_RESET",
      },
    );
  }

  static Future registerUser(
      {@required String apiKey,
      @required String email,
      String password}) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: email, name: "email");

    var response = await _sendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.RegisterUser,
      params: {
        "email": email,
        "password": password ?? uuid.v4(),
      },
    );
//    print("response for registration :" + jsonEncode(response));
//    print("waiting...");

    //await Future.delayed(const Duration(seconds: 5), () => {});

    await sendResetLink(apiKey: apiKey, email: email);
  }

  static Future<FauiUser> signInUser({
    @required String apiKey,
    @required String email,
    @required String password,
  }) async {
    FauiUtil.ThrowIfNullOrEmpty(value: apiKey, name: "apiKey");
    FauiUtil.ThrowIfNullOrEmpty(value: email, name: "email");
    FauiUtil.ThrowIfNullOrEmpty(value: password, name: "password");

    var response = await _sendFbApiRequest(
      apiKey: apiKey,
      action: FirebaseActions.SignIn,
      params: {
        "email": email,
        "password": password,
      },
    );

    Map<String, dynamic> parsedToken = FauiUtil.ParseJwt(response['idToken']);

    var user = FauiUser(
      email: response['email'],
      userId: parsedToken["userId"] ?? parsedToken["user_id"],
      token: response['idToken'],
    );

    if (user.email == null)
      throw Exception(
          "Email is not expected to be null in Firebase response for action");
    if (user.userId == null)
      throw Exception(
          "UserId is not expected to be null in Firebase response for action");
    return user;
  }

  static dynamic _sendFbApiRequest({
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
    _PrintResponse(response);
    throw FbException(message + response.body);
  }

  static void _PrintResponse(dynamic response) {
    if (response is Response) {
      print("code: " + response.statusCode.toString());
      print("response body: " + response.body);
      print("reason: " + response.reasonPhrase);
      return;
    }
    print("canot print response of type ${response.runtimeType.toString()}");
  }
}

//https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:delete?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]
class FirebaseActions {
  static const SendResetLink = "sendOobCode";
  static const DeleteAccount = "delete";
  static const RegisterUser = "signUp";
  static const SignIn = "signInWithPassword";
}
