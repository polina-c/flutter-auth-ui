import 'dart:convert' show utf8, base64, jsonEncode;

import '../90_model/faui_user.dart';
import '../90_model/faui_db.dart';
import 'db_connector.dart';

class FauiDbAccess {
  final FauiDb db;
  final String idToken;

  FauiDbAccess(this.db, this.idToken);

  Future<void> saveDoc(
    String collection,
    String docId,
    Map<String, dynamic> content,
  ) async {
    var fbDoc = {
      "fields": {
        for (var key in content.keys)
          key: {_fbType(content[key]): _fbValue(content[key])}
      }
    };

    await DbConnector.patch(db, idToken, collection, docId, fbDoc);
  }

  dynamic _fbValue(dynamic value) {
    if (_fbType(value) != "bytesValue") {
      return value;
    }

    return base64.encode(utf8.encode(jsonEncode(value)));
  }

  String _fbType(dynamic value) {
    // https://firebase.google.com/docs/firestore/reference/rest/v1beta1/Value
    return value == null
        ? "nullValue"
        : value is String
            ? "stringValue"
            : value is bool
                ? "booleanValue"
                : value is int
                    ? "integerValue"
                    : value is double ? "doubleValue" : "bytesValue";
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
