import 'package:faui/FauiUser.dart';
import 'package:faui/src/05_db/DbConnector.dart';
import 'package:faui/src/06_auth/AuthConnector.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../testUtil/Config.dart';

final uuid = new Uuid();

void main() {
  test('Create document', () async {
    final String id = uuid.v4();
    final String email = "_test_$id@fakedomain.com";

    await AuthConnector.registerUser(
        apiKey: Config.ApiKey, email: email, password: id);

    FauiUser user = await AuthConnector.signInUser(
        apiKey: Config.ApiKey, email: email, password: id);

    await DbConnector.upsert(apiKey: Config.ApiKey, idToken: user.token);

    await AuthConnector.deleteUserIfExists(
        apiKey: Config.ApiKey, idToken: user.token);
  });
}
