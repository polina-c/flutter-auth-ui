import 'package:http/http.dart';

class FbCodes {
  static const UserNotFoundCode = "USER_NOT_FOUND";
  static const EmailNotFoundCode = "EMAIL_NOT_FOUND";
  static const InvalidEmailCode = "INVALID_EMAIL";
  static const InvalidPasswordCode = "INVALID_PASSWORD";
  static const EmailExistsCode = "EMAIL_EXISTS";
  static const DocumentNotFoundCode = "NOT_FOUND";
}

void throwIfNullOrEmpty({String value, String name}) {
  if (value == null) {
    throw ArgumentError("$name should not be null");
  }
  if (value.isEmpty) {
    throw ArgumentError("$name should not be empty");
  }
}

class FauiException {
  final String message;
  FauiException(this.message);

  static String exceptionToUiMessage(dynamic exception) {
    if (exception is String) return exception;

    if (exception is FauiException) {
      if (exception.message.contains(FbCodes.UserNotFoundCode))
        return "User not found.";
      if (exception.message.contains(FbCodes.EmailNotFoundCode))
        return "EMail not found.";
      if (exception.message.contains(FbCodes.InvalidEmailCode))
        return "Invalid EMail.";
      if (exception.message.contains(FbCodes.InvalidPasswordCode))
        return "Invalid password.";
      if (exception.message.contains(FbCodes.EmailExistsCode))
        return "This email is already registered.";
    }

    if (exception is ClientException) {
      ClientException clientException = exception;

      if (clientException.message.contains("HttpRequest error"))
        return "Issues with internet connection.";
    }

    print(
        "Unexpected error in flutter-auth-ui of type ${exception.runtimeType}: " +
            exception.toString());

    return "Unexpected error. Check console for details.";
  }
}
