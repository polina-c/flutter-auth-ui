import 'dart:core';
import 'package:meta/meta.dart';

class FauiDb {
  final String apiKey;
  final String db;
  final String projectId;

  FauiDb({
    @required this.apiKey,
    @required this.db,
    @required this.projectId,
  });
}
