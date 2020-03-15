import 'package:faui/src/90_utility/util.dart';
import 'package:test/test.dart';

import '../../../lib/src/10_data/faui_db_access.dart';
import '../../../lib/src/90_model/faui_user.dart';
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

  test("List docs", () async {
    // prepare
    var collection = 'test', field = "field1", v1 = newId(), v2 = newId();
    var dbAccess = FauiDbAccess(testDb, user.token);

    var content = <String, Map<String, dynamic>>{
      newId(): {field: v1},
      newId(): {field: v2},
      newId(): {field: v2},
    };

    var futures = content.keys
        .map((id) => dbAccess.saveDoc(collection, id, content[id]))
        .toList();
    await Future.wait(futures);

    // test
    List<Map<String, dynamic>> list =
        await dbAccess.listDocsByStringValue(collection, field, v2);
    expect(list.length, 2);
    expect(list[0][field], v2);

    // clean up
    futures =
        content.keys.map((id) => dbAccess.deleteDoc(collection, id)).toList();
    await Future.wait(futures);
  });

  test('Write, read and delete doc', () async {
    // prepare
    var docId = 'doc1';
    var collection = 'test';
    var dbAccess = FauiDbAccess(testDb, user.token);

    Map<String, dynamic> content1 = {
      "bool": true,
      "int": 12,
      "double": 1.2,
      "string": "hello",
      "other": [1, 2, 3, 4],
      "null": null,
    };

    // write
    await dbAccess.saveDoc(collection, docId, content1);

    // read
    Map<String, dynamic> content2 = await dbAccess.loadDoc(collection, docId);

    // validate
    for (var key in content1.keys) {
      expect(content1[key], content2[key]);
    }

    // delete
    await dbAccess.deleteDoc(collection, docId);
    await dbAccess.deleteDoc(collection, docId);

    // validate
    Map<String, dynamic> content3 = await dbAccess.loadDoc(collection, docId);
    expect(content3, null);
  });
}
