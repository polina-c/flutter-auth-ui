import 'dart:collection';
import 'dart:core';

import '../90_infra/faui_error.dart';
import '../90_infra/faui_http.dart';
import '../90_model/faui_db.dart';

// https://cloud.google.com/firestore/docs/reference/rest/?apix=true
// https://stackoverflow.com/questions/46632042/how-to-perform-compound-queries-with-logical-or-in-cloud-firestore
//
Future<List<dynamic>> dbQuery(
  FauiDb db,
  String idToken,
  Map<String, dynamic> content,
) async {
  return await _sendFbApiRequest(
    db,
    FauiHttpMethod.post,
    "runQuery",
    idToken,
    content: content,
  );
}

Future<void> dbPatchDoc(
  FauiDb db,
  String idToken,
  String collection,
  String docId,
  Map<String, dynamic> content,
) async {
  await _sendFbApiDocRequest(
    db,
    collection,
    docId,
    FauiHttpMethod.patch,
    idToken,
    content: content,
  );
}

Future<Map<String, dynamic>> dbGetDoc(
  FauiDb db,
  String idToken,
  String collection,
  String docId,
) async {
  return await _sendFbApiDocRequest(
    db,
    collection,
    docId,
    FauiHttpMethod.get,
    idToken,
    acceptableWordsInErrorBody:
        HashSet.from({FirebaseErrorCodes.DocumentNotFoundCode}),
  );
}

Future<void> dbDeleteDoc(
  FauiDb db,
  String idToken,
  String collection,
  String docId,
) async {
  return await _sendFbApiDocRequest(
    db,
    collection,
    docId,
    FauiHttpMethod.delete,
    idToken,
  );
}

const String _fbApiUrl = "https://firestore.googleapis.com/v1/";

Future<Map<String, dynamic>> _sendFbApiDocRequest(
  FauiDb db,
  String collection,
  String docId,
  FauiHttpMethod operation,
  String idToken, {
  HashSet<String> acceptableWordsInErrorBody,
  Map<String, dynamic> content,
}) async {
  String url = "${_fbApiUrl}projects/" +
      "${db.projectId}/databases/${db.db}/documents/$collection/$docId/?key=${db.apiKey}";

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $idToken',
  };

  Map<String, dynamic> map = await sendFauiHttp(operation, headers, url,
      content, acceptableWordsInErrorBody, operation.toString());
  return map;
}

Future<List<dynamic>> _sendFbApiRequest(
  FauiDb db,
  FauiHttpMethod operation,
  String command,
  String idToken, {
  HashSet<String> acceptableWordsInErrorBody,
  Map<String, dynamic> content,
}) async {
  String url = "${_fbApiUrl}projects/" +
      "${db.projectId}/databases/${db.db}/documents:$command/?key=${db.apiKey}";

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $idToken',
  };

  List<dynamic> list = await sendFauiHttp(operation, headers, url, content,
      acceptableWordsInErrorBody, operation.toString());
  return list;
}
