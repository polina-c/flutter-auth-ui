import 'dart:convert';

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
    var collection = 'test';
    var dbAccess = FauiDbAccess(testDb, user.token);

    var content = <Map<String, dynamic>>[
      {
        "message": "message 1",
      },
      {
        "message": "message 2",
      },
    ];

    var futures =
        content.map((d) => dbAccess.saveDoc(collection, newId(), d)).toList();

    await Future.wait(futures);
    var list = await dbAccess.listDocs(collection);

    print(jsonEncode(list));
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
