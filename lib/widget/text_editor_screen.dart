import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';

class TextEditorScreen extends StatefulWidget {
  const TextEditorScreen({
    super.key,
    required this.initialValue,
    required this.valueTypeName,
    this.onChanged,
  });

  final String valueTypeName;
  final String initialValue;
  final Function(String value)? onChanged;

  @override
  State<StatefulWidget> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final _controller = CodeLineEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = jsonPrettify(widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    _controller.text = jsonPrettify(_controller.text);
                  },
                  style: const ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(
                      Colors.greenAccent,
                    ),
                  ),
                  child: const Text('Format'),
                )
              ],
            ),
          ),
          Expanded(
            child: CodeEditor(
              shortcutsActivatorsBuilder:
                  const DefaultCodeShortcutsActivatorsBuilder(),
              controller: _controller,
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
    widget.onChanged?.call(jsonMinify(_controller.text));
  }

  String jsonPrettify(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      final spaces = ' ' * 4;
      final encoder = JsonEncoder.withIndent(spaces);
      return encoder.convert(json);
    } on FormatException catch (_) {
      return jsonString;
    }
  }

  String jsonMinify(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      var encoder = const JsonEncoder();
      return encoder.convert(json);
    } on FormatException catch (_) {
      return jsonString;
    }
  }
}
