import 'dart:collection';
import 'dart:convert';

import 'package:faui/src/09_utility/FbException.dart';
import 'package:faui/src/09_utility/HttpMethod.dart';
import 'package:http/http.dart';

class Http {
  static Future<Map<String, dynamic>> send(
    HttpMethod method,
    Map<String, String> headers,
    String url,
    Map<String, dynamic> content,
    HashSet<String> acceptableWordsInErrorBody,
    String actionToLog,
  ) async {
    Response response;
    switch (method) {
      case HttpMethod.get:
        response = await get(
          url,
          headers: headers,
        );
        break;
      case HttpMethod.patch:
        response = await patch(
          url,
          body: jsonEncode(content),
          headers: headers,
        );
        break;
      case HttpMethod.post:
        response = await post(
          url,
          body: jsonEncode(content),
          headers: headers,
        );
        break;

      default:
        throw ("unexpected method ${method.toString()}");
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
    throw FbException(message + response.body);
  }

  static void _printResponse(dynamic response) {
    if (response is Response) {
      print("code: " + response.statusCode.toString());
      print("response body: " + response.body);
      print("reason: " + response.reasonPhrase);
      return;
    }
    print(
        "Could not print response of type ${response.runtimeType.toString()}");
  }
}
