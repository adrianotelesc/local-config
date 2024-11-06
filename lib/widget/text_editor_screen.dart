import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';

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
  final _textController = CodeLineEditingController();
  int maxCharsPerLine = 0;
  double textFieldWidth = 300.0;

  String _value = '';
  List<int> numLines = [];
  final textStyle = const TextStyle(fontSize: 16.0);

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    try {
      _textController.text = prettify(jsonDecode(_value));
    } on FormatException catch (_) {}
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.valueTypeName} editor'),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: () {
              onChanged();
              Navigator.maybePop(context);
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent),
              color: const Color.fromARGB(37, 76, 175, 79),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                ),
                const SizedBox.square(
                  dimension: 8,
                ),
                Text(
                  'Valid JSON',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.greenAccent),
                ),
                const Spacer(),
                TextButton(
                    onPressed: () {
                      _textController.text = prettify(jsonDecode(_value));
                    },
                    style: const ButtonStyle(
                      foregroundColor:
                          WidgetStatePropertyAll(Colors.greenAccent),
                    ),
                    child: const Text('Format'))
              ],
            ),
          ),
          Expanded(
            child: CodeEditor(
              shortcutsActivatorsBuilder:
                  const DefaultCodeShortcutsActivatorsBuilder(),
              controller: _textController,
              indicatorBuilder:
                  (context, editingController, chunkController, notifier) {
                return Row(
                  children: [
                    DefaultCodeLineNumber(
                      controller: editingController,
                      notifier: notifier,
                    ),
                    DefaultCodeChunkIndicator(
                        width: 20,
                        controller: chunkController,
                        notifier: notifier)
                  ],
                );
              },
              style: CodeEditorStyle(
                fontSize: 16,
                codeTheme: CodeHighlightTheme(
                  languages: {'json': CodeHighlightThemeMode(mode: langJson)},
                  theme: atomOneDarkTheme,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void onChanged() {
    widget.onChanged?.call(unprettify(jsonDecode(_textController.text)));
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
