import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../lib/FaConnector.dart';
import '../lib/FaUser.dart';

final uuid = new Uuid();
final apiKey = "AIzaSyA3hshWKqeogfYiklVCCtDaWJW8TfgWgB4";

void main() {
  test('Register, sign-in, send reset, delete and delete', () async {
    final String id = uuid.v4();
    final String email = "${id}@fakedomain.com";

    FaUser user = await FaConnector.registerUser(
        apiKey: apiKey, email: email, password: id);
    user = await FaConnector.signInUser(
        apiKey: apiKey, email: email, password: id);
    await FaConnector.sendResetLink(apiKey: apiKey, email: email);
    await FaConnector.deleteUserIfExists(apiKey: apiKey, idToken: user.idToken);
    await FaConnector.deleteUserIfExists(apiKey: apiKey, idToken: user.idToken);
  });

  test('Register fails if user exists', () async {
    final String id = uuid.v4();
    final String email = "${id}@fakedomain.com";

    FaUser user = await FaConnector.registerUser(
        apiKey: apiKey, email: email, password: id);

    try {
      await FaConnector.registerUser(
          apiKey: apiKey, email: email, password: id);
    } on Exception catch (exception) {
      expect(exception.toString().contains("EMAIL_EXISTS"), true);
    }

    await FaConnector.deleteUserIfExists(apiKey: apiKey, idToken: user.idToken);
  });
}
