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
    final String email = "${id}@fakedomain.com";

    FauiUser user = await FbConnector.registerUser(
        apiKey: apiKey, email: email, password: id);
    user = await FbConnector.signInUser(
        apiKey: apiKey, email: email, password: id);
    await FbConnector.sendResetLink(apiKey: apiKey, email: email);
    await FbConnector.deleteUserIfExists(apiKey: apiKey, idToken: user.token);
    await FbConnector.deleteUserIfExists(apiKey: apiKey, idToken: user.token);
  });

  test('Register fails if user exists', () async {
    final String id = uuid.v4();
    final String email = "${id}@fakedomain.com";

    FauiUser user =
        await FbConnector.registerUser(apiKey: apiKey, email: email);

    try {
      await FbConnector.registerUser(apiKey: apiKey, email: email);
    } on Exception catch (exception) {
      expect(
          FauiExceptionAnalyser.ToUiMessage(exception)
              .contains("already registered"),
          true);
    }

    await FbConnector.deleteUserIfExists(apiKey: apiKey, idToken: user.token);
  });
}
