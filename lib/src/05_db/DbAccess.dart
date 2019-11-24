import 'package:faui/FauiUser.dart';
import 'package:meta/meta.dart';
import 'package:faui/FauiDb.dart';
import 'package:faui/src/05_db/DbConnector.dart';

class DbAccess {
  static Future<void> save({
    @required FauiDb db,
    @required String docId,
    @required String key,
    @required String value,
    @required FauiUser user,
  }) async {
    await DbConnector.patch(
      collection: key,
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

  static Future<String> get({
    @required FauiDb db,
    @required String docId,
    @required String key,
    @required FauiUser user,
  }) async {
    dynamic record = await DbConnector.get(
      collection: key,
      db: db,
      docId: docId,
      idToken: user.token,
    );

    return record == null ? null : record["fields"]["value"]["stringValue"];
  }
}
