import 'package:faui/FauiDb.dart';
import 'package:faui/FauiUser.dart';
import 'package:faui/src/05_db/DbAccess.dart';
import 'package:flutter/material.dart';

class FauiTextField extends StatefulWidget {
  final FauiDb db;
  final FauiUser user;
  final dynamic decoration;
  final TextEditingController controller;

  FauiTextField(
    this.db,
    this.user, {
    this.decoration,
    TextEditingController controller,
  }) : controller = controller ?? new TextEditingController();

  @override
  _FauiTextFieldState createState() => _FauiTextFieldState();
}

class _FauiTextFieldState extends State<FauiTextField> {
  @override
  void initState() {
    super.initState();
    _loadValue();
    widget.controller.addListener(_saveValue);
  }

  _loadValue() async {
    String value = await DbAccess.load(
      db: widget.db,
      docId: "doc1",
      key: "key1",
      user: widget.user,
    );
    print("loaded: $value");

    this.setState(() {
      widget.controller.text = value;
    });
  }

  _saveValue() async {
    await DbAccess.save(
      db: widget.db,
      docId: "doc1",
      key: "key1",
      user: widget.user,
      value: widget.controller.text,
    );
    print("saved: ${widget.controller.text}");
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: widget.decoration,
      controller: widget.controller,
    );
  }
}
