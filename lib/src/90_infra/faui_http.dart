import 'dart:collection';
import 'dart:convert';

import 'package:faui/src/90_utility/util.dart';
import 'package:http/http.dart';

import 'faui_error.dart';

enum FauiHttpMethod {
  patch,
  get,
  post,
  delete,
}

Future<T> sendFauiHttp<T>(
  FauiHttpMethod method,
  Map<String, String> headers,
  String url,
  Map<String, dynamic> content,
  HashSet<String> acceptableWordsInErrorBody,
  String actionToLog,
) async {
  Response response;
  switch (method) {
    case FauiHttpMethod.get:
      fauiAssert(content == null, "Content should be null fot http get.");
      response = await get(
        url,
        headers: headers,
      );
      break;
    case FauiHttpMethod.patch:
      response = await patch(
        url,
        body: jsonEncode(content),
        headers: headers,
      );
      break;
    case FauiHttpMethod.post:
      response = await post(
        url,
        body: jsonEncode(content),
        headers: headers,
      );
      break;
    case FauiHttpMethod.delete:
      fauiAssert(content == null, "Content should be null for http delete.");
      response = await delete(
        url,
        headers: headers,
      );
      break;
    default:
      throw Error.safeToString("unexpected method ${method.toString()}");
  }

  if (response.statusCode == 200) {
    T map = json.decode(response.body);
    return map;
  }

  if (acceptableWordsInErrorBody != null) {
    for (String error in acceptableWordsInErrorBody) {
      if (response.body.contains(error)) {
        return null;
      }
    }
  }

  String message = "Error requesting firebase api: $actionToLog.";
  throw FauiError(message + response.body, FauiFailures.dependency);
}
