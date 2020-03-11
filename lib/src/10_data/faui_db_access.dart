import 'dart:convert' show utf8, base64, jsonEncode, jsonDecode;

import 'package:faui/src/10_data/doc_converter.dart';

import '../90_model/faui_db.dart';
import 'db_connector.dart' as db_connector;

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

    await db_connector.dbPatchDoc(
        db, token, collection, docId, map2doc(content));
  }

  //Future<List<Map<String, dynamic>>>
  Future<List<Map<String, dynamic>>> listDocsByStringValue(
    String collection,
    String field,
    String value,
  ) async {
    // https://cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.documents/runQuery

    Map<String, dynamic> query = {
      "structuredQuery": {
        "where": {
          "fieldFilter": {
            "field": {"fieldPath": field},
            "op": "EQUAL",
            "value": {"stringValue": value}
          }
        },
        "from": [
          {"collectionId": collection}
        ]
      }
    };

    List<dynamic> result =
        await db_connector.dbPostCommand(db, token, "runQuery", query);

    for (Map<String, dynamic> record in result) {
      print(jsonEncode(record)); ??????
    }

    return null;
  }

  Future<Map<String, dynamic>> loadDoc(
    String collection,
    String docId,
  ) async {
    // https: //cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.documents/get

    Map<String, dynamic> doc =
        await db_connector.dbGetDoc(db, token, collection, docId);

    String error = "Firebase returned unexpected data format for collection "
        "$collection, docId $docId";

    return doc2map(doc, error);
  }

  Future<void> deleteDoc(
    String collection,
    String docId,
  ) async {
    await db_connector.dbDeleteDoc(db, token, collection, docId);
  }
}
