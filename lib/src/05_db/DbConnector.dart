import 'dart:collection';
import 'dart:core';

import 'package:faui/src/09_utility/FbException.dart';
import 'package:faui/src/09_utility/Http.dart';
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
    @required Map<String, dynamic> content,
  }) async {
    await _sendFbApiRequest(
      collection: collection,
      db: db,
      docId: docId,
      idToken: idToken,
      content: content,
      operation: HttpMethod.patch,
      acceptableWordsInErrorBody: null,
    );
  }

  static Future<Map<String, dynamic>> get({
    @required FauiDb db,
    @required String idToken,
    @required String collection,
    @required String docId,
  }) async {
    return await _sendFbApiRequest(
      collection: collection,
      db: db,
      docId: docId,
      idToken: idToken,
      content: null,
      operation: HttpMethod.get,
      acceptableWordsInErrorBody:
          HashSet.from({FbException.DocumentNotFoundCode}),
    );
  }

  static Future<Map<String, dynamic>> _sendFbApiRequest({
    @required FauiDb db,
    @required String idToken,
    @required String collection,
    @required String docId,
    @required Map<String, dynamic> content,
    @required HttpMethod operation,
    @required HashSet<String> acceptableWordsInErrorBody,
  }) async {
    String url = "https://firestore.googleapis.com/v1beta1/projects/" +
        "${db.projectId}/databases/${db.db}/documents/$collection/$docId/?key=${db.apiKey}";

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    Map<String, dynamic> map = await Http.send(operation, headers, url, content,
        acceptableWordsInErrorBody, operation.toString());
    return map;
  }
}
