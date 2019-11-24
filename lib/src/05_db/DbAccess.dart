import 'package:faui/FauiUser.dart';
import 'package:meta/meta.dart';
import 'package:faui/FauiDb.dart';
import 'package:faui/src/05_db/DbConnector.dart';

class DbAccess {
  static Future<void> save({
    @required FauiDb db,
    @required String docId,
    @required String elementId,
    @required String value,
    @required FauiUser user,
  }) async {
    await DbConnector.upsert(
      collection: elementId,
      content: {
        "fields": {
          "value": {"stringValue": value},
          "user": {"stringValue": user.userId},
        }
      },
      db: db,
      docId: docId,
      idToken: user.token,
    );
  }
}
