import 'dart:collection';
import 'dart:core';

import '../90_infra/faui_http.dart';
import '../90_utility/util.dart';
import '../90_infra/faui_error.dart';
import '../90_model/faui_user.dart';

// https://firebase.google.com/docs/reference/rest/auth

Future<void> fauiDeleteUserIfExists({
  String apiKey,
  String idToken,
}) async {
  FauiError.throwIfEmpty(apiKey, "apiKey", FauiFailures.arg);
  FauiError.throwIfEmpty(idToken, "idToken", FauiFailures.arg);

  await _sendFbApiRequest(
    apiKey: apiKey,
    action: _FirebaseActions.DeleteAccount,
    content: {
      "idToken": idToken,
    },
    acceptableWordsInErrorBody:
        HashSet.from({FirebaseErrorCodes.UserNotFoundCode}),
  );
}

fauiRegisterUser({
  String apiKey,
  String email,
  String password,
  bool sendResetLink: true,
}) async {
  FauiError.throwIfEmpty(apiKey, "apiKey", FauiFailures.arg);
  FauiError.throwIfEmpty(email, "email", FauiFailures.user);

  await _sendFbApiRequest(
    apiKey: apiKey,
    action: _FirebaseActions.RegisterUser,
    content: {
      "email": email,
      "password": password ?? newId(),
    },
  );

  if (sendResetLink) {
    await _sendResetLink(apiKey: apiKey, email: email);
  }
}

Future<FauiUser> fauiSignInUser({
  String apiKey,
  String email,
  String password,
}) async {
  FauiError.throwIfEmpty(apiKey, "apiKey", FauiFailures.arg);
  FauiError.throwIfEmpty(email, "email", FauiFailures.user);
  FauiError.throwIfEmpty(password, "password", FauiFailures.user);

  Map<String, dynamic> response = await _sendFbApiRequest(
    apiKey: apiKey,
    action: _FirebaseActions.SignIn,
    content: {
      "email": email,
      "password": password,
      "returnSecureToken": true,
    },
  );

  FauiUser user = _firebaseResponseToUser(response);

  if (user.email == null)
    throw Exception(
        "Email is not expected to be null in Firebase response for sign in");
  if (user.userId == null)
    throw Exception(
        "UserId is not expected to be null in Firebase response for sign in");

  return user;
}

Future<FauiUser> fauiVerifyToken({
  String apiKey,
  String token,
}) async {
  FauiError.throwIfEmpty(apiKey, "apiKey", FauiFailures.arg);
  FauiError.throwIfEmpty(token, "token", FauiFailures.arg);

  Map<String, dynamic> response = await _sendFbApiRequest(
    apiKey: apiKey,
    action: _FirebaseActions.Verify,
    content: {
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

Future<void> _sendResetLink({
  String apiKey,
  String email,
}) async {
  FauiError.throwIfEmpty(apiKey, "apiKey", FauiFailures.arg);
  FauiError.throwIfEmpty(email, "email", FauiFailures.user);
  await _sendFbApiRequest(
    apiKey: apiKey,
    action: _FirebaseActions.SendResetLink,
    content: {
      "email": email,
      "requestType": "PASSWORD_RESET",
    },
  );
}

FauiUser _firebaseResponseToUser(Map<String, dynamic> response) {
  String idToken = response['idToken'] ?? response['id_token'];

  Map<String, dynamic> parsedToken = parseJwt(idToken);

  var user = FauiUser(
    email: response['email'] ?? parsedToken['email'],
    userId: parsedToken["userId"] ?? parsedToken["user_id"],
    token: idToken,
    refreshToken: response['refreshToken'] ?? response['refresh_token'],
  );

  return user;
}

Future<Map<String, dynamic>> _sendFbApiRequest({
  String apiKey,
  String action,
  Map<String, dynamic> content,
  HashSet<String> acceptableWordsInErrorBody,
}) async {
  FauiError.throwIfEmpty(apiKey, "apiKey", FauiFailures.arg);
  FauiError.throwIfEmpty(action, "action", FauiFailures.arg);

  Map<String, String> headers = {'Content-Type': 'application/json'};
  String url =
      "https://identitytoolkit.googleapis.com/v1/accounts:$action?key=$apiKey";

  return await sendFauiHttp(
    FauiHttpMethod.post,
    headers,
    url,
    content,
    acceptableWordsInErrorBody,
    action,
  );
}

Future<FauiUser> fauiRefreshToken({FauiUser user, String apiKey}) async {
  FauiError.throwIfEmpty(apiKey, "apiKey", FauiFailures.arg);
  FauiError.throwIfEmpty(user.refreshToken, "apiKey", FauiFailures.arg);

  Map<String, String> headers = {'Content-Type': 'application/json'};
  String url = "https://securetoken.googleapis.com/v1/token?key=$apiKey";
  Map<String, dynamic> content = {
    "grant_type": "refresh_token",
    "refresh_token": user.refreshToken,
  };

  Map<String, dynamic> response = await sendFauiHttp(
    FauiHttpMethod.post,
    headers,
    url,
    content,
    null,
    "refresh_token",
  );

  return _firebaseResponseToUser(response);
}

//https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:delete?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]
//https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=[API_KEY]
class _FirebaseActions {
  static const SendResetLink = "sendOobCode";
  static const DeleteAccount = "delete";
  static const RegisterUser = "signUp";
  static const SignIn = "signInWithPassword";
  static const Verify = "lookup";
}
