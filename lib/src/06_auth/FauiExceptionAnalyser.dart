import 'package:faui/src/09_utility/FbException.dart';
import 'package:http/http.dart';

class FauiExceptionAnalyser {
  static String toUiMessage(dynamic exception) {
    if (exception is String) return exception;

    if (exception is FbException) {
      if (exception.message.contains(FbException.UserNotFoundCode))
        return "User not found.";
      if (exception.message.contains(FbException.EmailNotFoundCode))
        return "EMail not found.";
      if (exception.message.contains(FbException.InvalidEmailCode))
        return "Invalid EMail.";
      if (exception.message.contains(FbException.InvalidPasswordCode))
        return "Invalid password.";
      if (exception.message.contains(FbException.EmailExistsCode))
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
