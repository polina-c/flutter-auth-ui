import 'dart:collection';
import 'dart:core';

import '../90_infra/faui_exception.dart';
import '../90_infra/faui_http.dart';

import '../90_model/faui_db.dart';

// https://firebase.google.com/docs/firestore/use-rest-api
class DbConnector {
  static Future<void> patch(
    FauiDb db,
    String idToken,
    String collection,
    String docId,
    Map<String, dynamic> content,
  ) async {
    await _sendFbApiRequest(
      db,
      collection,
      docId,
      FauiHttpMethod.patch,
      idToken,
      content: content,
      acceptableWordsInErrorBody: null,
    );
  }

  static Future<Map<String, dynamic>> get(
    FauiDb db,
    String idToken,
    String collection,
    String docId,
  ) async {
    return await _sendFbApiRequest(
      db,
      collection,
      docId,
      FauiHttpMethod.get,
      idToken,
      acceptableWordsInErrorBody: HashSet.from({FbCodes.DocumentNotFoundCode}),
    );
  }

  static Future<Map<String, dynamic>> _sendFbApiRequest(
    FauiDb db,
    String collection,
    String docId,
    FauiHttpMethod operation,
    String idToken, {
    HashSet<String> acceptableWordsInErrorBody,
    Map<String, dynamic> content,
  }) async {
    String url = "https://firestore.googleapis.com/v1beta1/projects/" +
        "${db.projectId}/databases/${db.db}/documents/$collection/$docId/?key=${db.apiKey}";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    Map<String, dynamic> map = await sendFauiHttp(operation, headers, url,
        content, acceptableWordsInErrorBody, operation.toString());
    return map;
  }
}
