import 'package:faui/src/05_db/DbConnector.dart';
import 'package:test/test.dart';

void main() {
  test('Create document', () async {
    await DbConnector.upsert();
  });
}
