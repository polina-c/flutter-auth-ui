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

Future<Map<String, dynamic>> sendFauiHttp(
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
    Map<String, dynamic> map = json.decode(response.body);
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
  print(message);
  _printResponse(response);
  throw FauiError(message + response.body, FauiFailures.dependency);
}

void _printResponse(dynamic response) {
  if (response is Response) {
    print("code: " + response.statusCode.toString());
    print("response body: " + response.body);
    print("reason: " + response.reasonPhrase);
    return;
  }
  print("Could not print response of type ${response.runtimeType.toString()}");
}
