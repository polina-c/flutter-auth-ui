import 'dart:convert';

import 'package:faui/src/09_utility/FbException.dart';
import 'package:faui/src/09_utility/HttpMethod.dart';
import 'package:http/http.dart';

class FauiUtil {
  static void throwIfNullOrEmpty({String value, String name}) {
    if (value == null) {
      throw "$name should not be null";
    }
    if (value.isEmpty) {
      throw "$name should not be empty";
    }
  }

  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  static Future<Object> http(
    HttpMethod method,
    Object headers,
    String url,
    Object content,
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
      default:
        throw ("unexpected method ${method.toString()}");
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      return map;
    }
    String action = "insert";

    reportFailedRequest(action, response);
    return null;
  }

  static void reportFailedRequest(String action, dynamic response) {
    String message = "Error requesting firebase api $action.";
    print(message);
    printResponse(response);
    throw FbException(message + response.body);
  }

  static void printResponse(dynamic response) {
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
