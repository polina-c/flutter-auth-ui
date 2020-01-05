import 'dart:convert' show utf8, base64, jsonEncode;
import '../90_model/faui_db.dart';
import 'db_connector.dart';

class _FbTypes {
  // https://firebase.google.com/docs/firestore/reference/rest/v1beta1/Value
  static const String nullV = "nullValue";
  static const String string = "stringValue";
  static const String bool = "booleanValue";
  static const String int = "integerValue";
  static const String double = "doubleValue";
  static const String bytes = "bytesValue";
}

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
          key: {_toFbType(content[key]): _toFbValue(content[key])}
      }
    };

    await DbConnector.patch(db, idToken, collection, docId, fbDoc);
  }

  Future<Map<String, dynamic>> loadDoc(
    String collection,
    String docId,
  ) async {
    dynamic record = await DbConnector.get(db, idToken, collection, docId);
    if (record == null) {
      return null;
    }

    for (var f in record["fields"])
      return record["fields"]["value"]["stringValue"];

    return null;
  }

  dynamic _toFbValue(dynamic value) {
    if (_toFbType(value) != _FbTypes.bytes) {
      return value;
    }

    return base64.encode(utf8.encode(jsonEncode(value)));
  }

  String _toFbType(dynamic value) {
    return value == null
        ? _FbTypes.nullV
        : value is String
            ? _FbTypes.string
            : value is bool
                ? _FbTypes.bool
                : value is int
                    ? _FbTypes.int
                    : value is double ? _FbTypes.double : _FbTypes.bytes;
  }
}
