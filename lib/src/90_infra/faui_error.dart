import 'package:http/http.dart';

import '../90_utility/util.dart';

/// Error codes, that can be returned by Firebase API and need to be processed
/// by this library.
class FirebaseErrorCodes {
  static const UserNotFoundCode = "USER_NOT_FOUND";
  static const EmailNotFoundCode = "EMAIL_NOT_FOUND";
  static const InvalidEmailCode = "INVALID_EMAIL";
  static const InvalidPasswordCode = "INVALID_PASSWORD";
  static const EmailExistsCode = "EMAIL_EXISTS";
  static const DocumentNotFoundCode = "NOT_FOUND";
}

/// Types of the library failure modes.
enum FauiFailures {
  arg,
  data,
  user,
  config,
  dependency,
}

/// An error that can be thrown by the library.
class FauiError extends Error {
  final FauiFailures type;
  final String message;
  FauiError(this.message, this.type);

  @override
  String toString() => '$runtimeType(this). $type. $message';

  static void throwIfEmpty(dynamic value, String name, FauiFailures failure) {
    if (!isEmpty(value)) {
      return;
    }

    if (failure == FauiFailures.user) {
      throw FauiError("$name should not be empty", FauiFailures.user);
    }
    throw FauiError("$name should not be empty, but it is $value", failure);
  }

  static String exceptionToUiMessage(dynamic exception) {
    if (exception is String) return exception;

    if (exception is FauiError && exception.type == FauiFailures.user) {
      return exception.message;
    }

    if (exception is FauiError) {
      if (exception.message.contains(FirebaseErrorCodes.UserNotFoundCode))
        return "User not found.";
      if (exception.message.contains(FirebaseErrorCodes.EmailNotFoundCode))
        return "EMail not found.";
      if (exception.message.contains(FirebaseErrorCodes.InvalidEmailCode))
        return "Invalid EMail.";
      if (exception.message.contains(FirebaseErrorCodes.InvalidPasswordCode))
        return "Invalid password.";
      if (exception.message.contains(FirebaseErrorCodes.EmailExistsCode))
        return "This email is already registered.";
    }

    if (exception is ClientException) {
      if (exception.message.contains("HttpRequest error"))
        return "Issues with internet connection.";
    }

    print(
        "Unexpected error in flutter-auth-ui of type ${exception.runtimeType}: " +
            exception.toString());

    return "Unexpected error. Check console for details.";
  }
}
