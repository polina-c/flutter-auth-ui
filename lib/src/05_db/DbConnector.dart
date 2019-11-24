import 'dart:convert';
import 'dart:core';

import 'package:faui/src/09_utility/FauiUtil.dart';
import 'package:faui/src/09_utility/HttpMethod.dart';
import 'package:meta/meta.dart';
import 'package:faui/FauiDb.dart';

// https://firebase.google.com/docs/firestore/use-rest-api
class DbConnector {
  static Future<void> patch({
    @required FauiDb db,
    @required String idToken,
    @required String collection,
    @required String docId,
    @required Object content,
  }) async {
    await _invoke(
      collection: collection,
      db: db,
      docId: docId,
      idToken: idToken,
      content: content,
      operation: HttpMethod.patch,
    );
  }

  static Future<Map<String, dynamic>> get({
    @required FauiDb db,
    @required String idToken,
    @required String collection,
    @required String docId,
  }) async {
    return await _invoke(
      collection: collection,
      db: db,
      docId: docId,
      idToken: idToken,
      content: null,
      operation: HttpMethod.get,
    );
  }

  static Future<Map<String, dynamic>> _invoke({
    @required FauiDb db,
    @required String idToken,
    @required String collection,
    @required String docId,
    @required Object content,
    @required HttpMethod operation,
  }) async {
    String url = "https://firestore.googleapis.com/v1beta1/projects/" +
        "${db.projectId}/databases/${db.db}/documents/$collection/$docId/?key=${db.apiKey}";

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    Map<String, dynamic> map =
        await FauiUtil.http(operation, headers, url, content);
    return map;
  }
}
