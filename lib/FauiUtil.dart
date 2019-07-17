import 'package:meta/meta.dart';

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
}
