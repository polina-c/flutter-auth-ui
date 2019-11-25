import 'package:faui/FauiUser.dart';
import 'package:faui/src/05_db/DbAccess.dart';
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

  test('Write and read', () async {
    String doc = 'doc1';
    String key = 'profile.name';
    String value1 = 'value of the field';

    await DbAccess.save(
      db: Config.db,
      user: user,
      docId: doc,
      key: key,
      value: value1,
    );

    String value2 = await DbAccess.get(
      db: Config.db,
      user: user,
      docId: doc,
      key: key,
    );

    expect(value2, value1);
  });

  test('Get non-existing key', () async {
    String doc = 'doc1';
    String key = 'non-existing-key';
    var value = await DbAccess.get(
      db: Config.db,
      user: user,
      docId: doc,
      key: key,
    );

    expect(value, null);
  });
}
