import 'dart:collection';
import 'dart:core';

import '../90_infra/faui_error.dart';
import '../90_infra/faui_http.dart';

import '../90_model/faui_db.dart';

// https://cloud.google.com/firestore/docs/reference/rest/?apix=true

Future<void> dbPatch(
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

Future<Map<String, dynamic>> dbGet(
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
    acceptableWordsInErrorBody:
        HashSet.from({FirebaseErrorCodes.DocumentNotFoundCode}),
  );
}

Future<void> dbDelete(
  FauiDb db,
  String idToken,
  String collection,
  String docId,
) async {
  return await _sendFbApiRequest(
    db,
    collection,
    docId,
    FauiHttpMethod.delete,
    idToken,
  );
}

Future<Map<String, dynamic>> _sendFbApiRequest(
  FauiDb db,
  String collection,
  String docId,
  FauiHttpMethod operation,
  String idToken, {
  HashSet<String> acceptableWordsInErrorBody,
  Map<String, dynamic> content,
}) async {
  String url = "https://firestore.googleapis.com/v1/projects/" +
      "${db.projectId}/databases/${db.db}/documents/$collection/$docId/?key=${db.apiKey}";

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $idToken',
  };

  Map<String, dynamic> map = await sendFauiHttp(operation, headers, url,
      content, acceptableWordsInErrorBody, operation.toString());
  return map;
}
