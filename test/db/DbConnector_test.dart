import 'package:faui/FauiUser.dart';
import 'package:faui/src/05_db/DbAccess.dart';
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
        apiKey: Config.Db.apiKey, email: email, password: id);

    FauiUser user = await AuthConnector.signInUser(
        apiKey: Config.Db.apiKey, email: email, password: id);

    await DbAccess.save(
      db: Config.Db,
      user: user,
      docId: "doc1",
      elementId: 'profile.name',
      value: 'Polina',
    );

    await AuthConnector.deleteUserIfExists(
        apiKey: Config.Db.apiKey, idToken: user.token);
  });
}
