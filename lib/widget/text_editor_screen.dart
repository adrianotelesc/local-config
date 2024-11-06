import 'dart:convert';

import 'package:firebase_local_config/text/styleable_text_editing_controller.dart';
import 'package:firebase_local_config/text/tab_shortcut.dart';
import 'package:firebase_local_config/text/text_part_style_definition.dart';
import 'package:firebase_local_config/text/text_part_style_definitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextEditorScreen extends StatefulWidget {
  const TextEditorScreen({
    super.key,
    required this.value,
    required this.valueTypeName,
    this.onChanged,
  });

  final String valueTypeName;
  final String value;
  final Function(String value)? onChanged;

  @override
  State<StatefulWidget> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = StyleableTextEditingController(
      styles: TextPartStyleDefinitions(
    definitionList: [
      TextPartStyleDefinition(
        pattern: r'"[^"]*"',
        style: const TextStyle(color: Colors.green),
      ),
      TextPartStyleDefinition(
        pattern: r'\d+\.?\d*|\.\d+|\btrue\b|\bfalse\b',
        style: const TextStyle(color: Colors.deepOrange),
      )
    ],
  ));

  String _value = '';

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    try {
      _textController.text = prettify(jsonDecode(_value));
    } on FormatException catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.valueTypeName} editor'),
      ),
      body: Form(
        key: _formKey,
        child: Actions(
          actions: {InsertTabIntent: InsertTabAction()},
          child: Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.tab):
                  InsertTabIntent(2, _textController)
            },
            child: TextFormField(
              maxLines: null,
              decoration: const InputDecoration(border: InputBorder.none),
              controller: _textController,
              autovalidateMode: AutovalidateMode.always,
              validator: (value) {
                try {
                  prettify(jsonDecode(_textController.text));
                } on FormatException catch (_) {
                  return 'Invalid JSON.';
                }

                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  String prettify(dynamic json) {
    var spaces = ' ' * 4;
    var encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(json);
  }

  String unprettify(dynamic json) {
    var encoder = const JsonEncoder();
    return encoder.convert(json);
  }
}
