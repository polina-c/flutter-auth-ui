class FbException implements Exception {
  static const UserNotFoundCode = "USER_NOT_FOUND";
  static const EmailNotFoundCode = "EMAIL_NOT_FOUND";
  static const InvalidEmailCode = "INVALID_EMAIL";
  static const InvalidPasswordCode = "INVALID_PASSWORD";
  static const EmailExistsCode = "EMAIL_EXISTS";

  final String message;
  FbException(this.message);
}
