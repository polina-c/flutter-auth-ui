import 'dart:convert';

import '../../faui_api.dart';

class _FbTypes {
  // https://firebase.google.com/docs/firestore/reference/rest/v1beta1/Value
  static const String nullV = "nullValue";
  static const String string = "stringValue";
  static const String bool = "booleanValue";
  static const String int = "integerValue";
  static const String double = "doubleValue";
  static const String bytes = "bytesValue";
}

String extractId(String docName) {
  // example of docName: "projects/flutterauth-c3973/databases/(default)/documents/test/240c35d4-0b0b-423f-ae80-55cd9f05ad4f"
  return docName.split("/").last;
}

Map<String, dynamic> map2doc(Map<String, dynamic> map) {
  Map<String, dynamic> fbDoc = {
    "fields": {
      for (var key in map.keys) key: {toFbType(map[key]): _toFbValue(map[key])}
    }
  };

  return fbDoc;
}

Map<String, dynamic> doc2map(
    Map<String, dynamic> doc, String descriptionForErrorLog) {
  if (doc == null) {
    return null;
  }

  try {
    var result = Map<String, dynamic>();
    for (String key in doc["fields"].keys) {
      String type = doc["fields"][key].keys.first;
      result[key] = _fromFbValue(doc["fields"][key][type], type);
    }
    return result;
  } catch (ex, trace) {
    throw FauiError(
        "$descriptionForErrorLog, with message '$ex', and trace: \n$trace",
        FauiFailures.data);
  }
}

dynamic _toFbValue(dynamic value) {
  if (toFbType(value) == _FbTypes.bytes) {
    return base64.encode(utf8.encode(jsonEncode(value)));
  }
  return value;
}

dynamic _fromFbValue(dynamic value, String type) {
  if (type == _FbTypes.bytes) {
    return jsonDecode(utf8.decode(base64.decode(value)));
  }
  if (type == _FbTypes.int) {
    return int.parse(value);
  }
  return value;
}

String toFbType(dynamic value) {
  return value == null
      ? _FbTypes.nullV
      : value is String
          ? _FbTypes.string
          : value is bool
              ? _FbTypes.bool
              : value is int
                  ? _FbTypes.int
                  : value is double ? _FbTypes.double : _FbTypes.bytes;
}
