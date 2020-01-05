import '../../../lib/src/10_data/faui_db_access.dart';

import '../../../lib/src/90_model/faui_user.dart';
import 'package:test/test.dart';
import '../../util/auth_util.dart';
import '../../util/test_db.dart';

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

    var dbAccess = FauiDbAccess(testDb, user.token);

    var content1 = {
      "bool": true,
      "int": 12,
      "double": 1.2,
      "string": "hello",
      "other": [1, 2, 3, 4],
      "null": null,
    };

    await dbAccess.saveDoc(collection, docId, content1);

    var content2 = await dbAccess.loadDoc(collection, docId);

    for (var key in content1.keys) {
      expect(content1[key], content2[key]);
    }
  });
}
