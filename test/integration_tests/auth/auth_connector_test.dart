import '../../../lib/src/10_auth/auth_connector.dart';
import '../../../lib/src/90_infra/faui_error.dart';
import '../../../lib/src/90_model/faui_user.dart';
import 'package:test/test.dart';
import '../../util/auth_util.dart';
import '../../util/test_db.dart';

void main() {
  FauiUser user;
  setUp(() async {
    user = await TestAuthUtil.signIn();
  });

  tearDown(() async {
    await TestAuthUtil.deleteUser(user);
  });

  test('Refresh token', () async {
    var user2 = await fauiRefreshToken(apiKey: testDb.apiKey, user: user);

    expect(user2.userId, user.userId);
    expect(user2.email, user.email);
    expect(user2.token != null, true);
  });

  test('Registration fails if user exists', () async {
    try {
      await fauiRegisterUser(
        apiKey: testDb.apiKey,
        email: user.email,
        password: "abcd12345HJ",
        sendResetLink: false,
      );
      expect(true, false);
    } on FauiError catch (exception) {
      expect(
          FauiError.exceptionToUiMessage(exception)
              .contains("already registered"),
          true);
    }
  });

  test('Token validation', () async {
    FauiUser user2 =
        await fauiVerifyToken(apiKey: testDb.apiKey, token: user.token);

    expect(user2.email, user.email);
    expect(user2.userId, user.userId);

    await fauiDeleteUserIfExists(apiKey: testDb.apiKey, idToken: user.token);
  });
}
