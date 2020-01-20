import 'dart:convert' show utf8, base64, jsonEncode, jsonDecode;

import '../90_infra/faui_error.dart';

import '../90_model/faui_db.dart';
import 'db_connector.dart' as db_connector;

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
  final String token;

  FauiDbAccess(this.db, this.token);

  Future<void> saveDoc(
    String collection,
    String docId,
    Map<String, dynamic> content,
  ) async {
    // https://cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.documents/patch

    Map<String, dynamic> fbDoc = {
      "fields": {
        for (var key in content.keys)
          key: {_toFbType(content[key]): _toFbValue(content[key])}
      }
    };

    await db_connector.dbPatch(db, token, collection, docId, fbDoc);
  }

  Future<Map<String, dynamic>> loadDoc(
    String collection,
    String docId,
  ) async {
    // https: //cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.documents/get

    var record = await db_connector.dbGet(db, token, collection, docId);
    if (record == null) {
      return null;
    }

    try {
      var result = Map<String, dynamic>();
      for (String key in record["fields"].keys) {
        String type = record["fields"][key].keys.first;
        result[key] = _fromFbValue(record["fields"][key][type], type);
      }
      return result;
    } catch (ex, trace) {
      throw FauiError(
          "Firebase returned unexpected data format for collection "
          "$collection, docId $docId, with message '$ex', and trace: \n$trace",
          FauiFailures.data);
    }
  }

  Future<void> deleteDoc(
    String collection,
    String docId,
  ) async {
    await db_connector.dbDelete(db, token, collection, docId);
  }

  dynamic _toFbValue(dynamic value) {
    if (_toFbType(value) == _FbTypes.bytes) {
      return base64.encode(utf8.encode(jsonEncode(value)));
    }
    return value;
  }

  dynamic _fromFbValue(dynamic value, String type) {
    if (type == _FbTypes.bytes) {
      return jsonDecode(utf8.decode(base64.decode(value)));
    }
    if (type == _FbTypes.int) {
      return int.parse(value);
    }
    return value;
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
