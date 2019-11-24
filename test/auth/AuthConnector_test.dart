import 'package:faui/FauiUser.dart';
import 'package:faui/src/06_auth/FauiExceptionAnalyser.dart';
import 'package:faui/src/06_auth/AuthConnector.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../testUtil/AuthUtil.dart';
import '../testUtil/Config.dart';

final uuid = new Uuid();

void main() {
  FauiUser user;
  setUp(() async {
    user = await AuthUtil.signIn();
  });

  tearDown(() async {
    await AuthUtil.deleteUser(user);
  });

  test('Register, sign-in, send reset, delete and delete', () async {
    await AuthConnector.sendResetLink(
        apiKey: Config.Db.apiKey, email: user.email);
    await AuthConnector.deleteUserIfExists(
        apiKey: Config.Db.apiKey, idToken: user.token);
    await AuthConnector.deleteUserIfExists(
        apiKey: Config.Db.apiKey, idToken: user.token);
  });

  test('Refresh token', () async {
    FauiUser user2 =
        await AuthConnector.refreshToken(apiKey: Config.Db.apiKey, user: user);

    expect(user2.userId, user.userId);
    expect(user2.email, user.email);
    expect(user2.token != null, true);
  });

  test('Registration fails if user exists', () async {
    try {
      await AuthConnector.registerUser(
          apiKey: Config.Db.apiKey, email: user.email);
      expect(true, false);
    } on Exception catch (exception) {
      expect(
          FauiExceptionAnalyser.toUiMessage(exception)
              .contains("already registered"),
          true);
    }
  });

  test('Token validation', () async {
    FauiUser user2 = await AuthConnector.verifyToken(
        apiKey: Config.Db.apiKey, token: user.token);

    expect(user2.email, user.email);
    expect(user2.userId, user.userId);

    await AuthConnector.deleteUserIfExists(
        apiKey: Config.Db.apiKey, idToken: user.token);
  });
}
