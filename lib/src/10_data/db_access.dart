import 'package:faui/src/90_model/faui_user.dart';
import 'db_connector.dart';
import 'package:faui/src/90_model/faui_db.dart';

class DbAccess {
  static Future<void> save(
    FauiDb db,
    String docId,
    String key,
    String value,
    FauiUser user,
  ) async {
//    await DbConnector.patch(db, user.userId, collection, docId, content)
//
//    patch(
//      key,
//      {
//        "fields": {
//          "value": {"stringValue": value},
//          "user": {"stringValue": user.userId},
//        }
//      },
//      db,
//      docId,
//      user.token,
//    );
  }

  static Future<String> load(
    FauiDb db,
    String docId,
    String key,
    FauiUser user,
  ) async {
//    dynamic record = await DbConnector.get(
//      collection: key,
//      db: db,
//      docId: docId,
//      idToken: user.token,
//    );
//
//    return record == null ? null : record["fields"]["value"]["stringValue"];

    return null;
  }
}
