import 'FbException.dart';

class FaExceptionAnalyser {
  static String ToUiMessage(Object exception) {
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
    }
    print(exception);
    return "Unexpected error. Check console for details.";
  }
}
