import 'package:faui/FauiUser.dart';
import 'package:faui/src/06_auth/AuthConnector.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../testUtil/Config.dart';

final uuid = new Uuid();

class AuthUtil {
  static Future<FauiUser> signIn() async {
    final String id = uuid.v4();
    final String email = "_test_$id@fakedomain.com";

    await AuthConnector.registerUser(
        apiKey: Config.Db.apiKey, email: email, password: id);

    FauiUser user = await AuthConnector.signInUser(
        apiKey: Config.Db.apiKey, email: email, password: id);

    expect(user.userId == null, false);
    expect(user.email, email);
    expect(user.token == null, false);

    return user;
  }

  static Future<void> deleteUser(FauiUser u) async {
    await AuthConnector.deleteUserIfExists(
        apiKey: Config.Db.apiKey, idToken: u.token);
  }
}
