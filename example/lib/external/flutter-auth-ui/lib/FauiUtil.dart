import 'dart:convert';

import 'package:flutter/material.dart';

class FauiUtil {
  static void ThrowIfNullOrEmpty(
      {@required String value, @required String name}) {
    if (value == null) {
      throw "$name should not be null";
    }
    if (value.isEmpty) {
      throw "$name should not be empty";
    }
  }

  static Map<String, dynamic> ParseJwt(String token) {
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
}
