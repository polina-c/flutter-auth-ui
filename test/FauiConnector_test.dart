import 'dart:core';

import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../lib/FauiExceptionAnalyser.dart';
import '../lib/FbConnector.dart';
import '../lib/faui_model.dart';

final uuid = new Uuid();
final apiKey = "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4";

void main() {
  test('Register, sign-in, send reset, delete and delete', () async {
    final String id = uuid.v4();
    final String email = "_test_${id}@fakedomain.com";

    await FbConnector.RegisterUser(apiKey: apiKey, email: email, password: id);

    FauiUser user = await FbConnector.SignInUser(
        apiKey: apiKey, email: email, password: id);

    expect(user.userId == null, false);
    expect(user.email, email);
    expect(user.token == null, false);
    await FbConnector.SendResetLink(apiKey: apiKey, email: email);
    await FbConnector.DeleteUserIfExists(apiKey: apiKey, idToken: user.token);
    await FbConnector.DeleteUserIfExists(apiKey: apiKey, idToken: user.token);
  });

  test('Refresh token', () async {
    final String id = uuid.v4();
    final String email = "_test_${id}@fakedomain.com";

    await FbConnector.RegisterUser(apiKey: apiKey, email: email, password: id);

    FauiUser user1 = await FbConnector.SignInUser(
        apiKey: apiKey, email: email, password: id);

    expect(user1.userId == null, false);
    expect(user1.email, email);
    expect(user1.token == null, false);

    FauiUser user2 =
        await FbConnector.RefreshToken(apiKey: apiKey, user: user1);

    expect(user2.userId, user1.userId);
    expect(user2.email, user1.email);
    expect(user2.token != user1.token, true);
    expect(user2.token != null, true);
  });

  test('Register fails if user exists', () async {
    final String id = uuid.v4();
    final String email = "_test_${id}@fakedomain.com";

    await FbConnector.RegisterUser(apiKey: apiKey, email: email, password: id);

    try {
      await FbConnector.RegisterUser(apiKey: apiKey, email: email);
      expect(true, false);
    } on Exception catch (exception) {
      expect(
          FauiExceptionAnalyser.ToUiMessage(exception)
              .contains("already registered"),
          true);
    }

    FauiUser user = await FbConnector.SignInUser(
        apiKey: apiKey, email: email, password: id);
    await FbConnector.DeleteUserIfExists(apiKey: apiKey, idToken: user.token);
  });
}
