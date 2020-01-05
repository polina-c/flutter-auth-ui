import '../../../lib/src/10_data/faui_db_access.dart';

import '../../../lib/src/90_model/faui_user.dart';
import 'package:test/test.dart';
import '../../util/auth_util.dart';
import '../../util/config.dart';

void main() {
  FauiUser user;
  setUp(() async {
    user = await AuthUtil.signIn();
  });

  tearDown(() async {
    await AuthUtil.deleteUser(user);
  });

  test('Write and read doc', () async {
    var docId = 'doc1';
    var collection = 'test';

    var content = {
      "bool": true,
      "int": 12,
      "double": 1.2,
      "string": "hello",
      "other": [1, 2, 3, 4],
      "null": null,
    };

    await FauiDbAccess(testDb, user.token).saveDoc(collection, docId, content);

//      (
//      Config.db,
//      docId: doc,
//      key: key,
//      value: value1,
//      user: user,
//    );

//    String value2 = await DbAccess.load(
//      db: Config.db,
//      user: user,
//      docId: doc,
//      key: key,
//    );
//
//    expect(value2, value1);
  });

//  test('Get non-existing key', () async {
//    String doc = 'doc1';
//    String key = 'non-existing-key';
//    var value = await DbAccess.load(
//      db: Config.db,
//      user: user,
//      docId: doc,
//      key: key,
//    );
//
//    expect(value, null);
//  });
}
