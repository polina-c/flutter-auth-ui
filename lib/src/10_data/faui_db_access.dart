import 'package:faui/src/10_data/doc_converter.dart';

import '../90_model/faui_db.dart';
import 'db_connector.dart' as db_connector;

/// A filter to be applied to a field when invoking [FauiDbAccess.listDocs].
class FilterItem {
  final String field;
  final String operation;
  final dynamic value;

  FilterItem(this.field, this.operation, this.value);
}

/// Filter operations to be applied when invoking [FauiDbAccess.listDocs].
class FilterOp {
  static const String lt = "LESS_THAN";
  static const String le = "LESS_THAN_OR_EQUAL";
  static const String gt = "GREATER_THAN";
  static const String ge = "GREATER_THAN_OR_EQUAL";
  static const String eq = "EQUAL";
  static const String ac = "ARRAY_CONTAINS";
  static const String iin = "IN";
  static const String any = "ARRAY_CONTAINS_ANY";
}

/// Provides access to Firebase DB.
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
  Future<List<Map<String, dynamic>>> listDocs(
    String collection, [
    List<FilterItem> filter,
  ]) async {
    // https://cloud.google.com/firestore/docs/reference/rest/v1/projects.databases.documents/runQuery
    // https://cloud.google.com/firestore/docs/reference/rest/?apix=true
    // https://stackoverflow.com/questions/46632042/how-to-perform-compound-queries-with-logical-or-in-cloud-firestore

    Map<String, dynamic> query = {
      "structuredQuery": {
        if (filter != null && filter.length > 0)
          "where": {
            "compositeFilter": {
              "op": "AND",
              "filters": filter
                  .map((f) => {
                        "fieldFilter": {
                          "field": {"fieldPath": f.field},
                          "op": f.operation,
                          "value": {toFbType(f.value): f.value}
                        }
                      })
                  .toList(),
            }
          },
        "from": [
          {"collectionId": collection}
        ]
      }
    };

    List<dynamic> result = await db_connector.dbQuery(db, token, query);

    if (result.length == 1) {
      var v = result[0];
      if (v is Map<String, dynamic> &&
          v.keys.length == 1 &&
          v.containsKey("readTime")) {
        return [];
      }
    }

    List<Map<String, dynamic>> docs = result
        .map((r) => doc2map(r["document"], "Faild to parse documents in list."))
        .toList();
    return docs;
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
