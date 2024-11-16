import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';

class TextEditorScreen extends StatefulWidget {
  const TextEditorScreen({
    super.key,
    required this.initialValue,
  });

  final String initialValue;

  @override
  State<StatefulWidget> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final _textController = CodeLineEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = jsonPrettify(widget.initialValue);
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
        title: const Text('Editor'),
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(
              context,
              widget.initialValue,
            );
          },
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: () {
              Navigator.maybePop(
                context,
                jsonMinify(_textController.text),
              );
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
                    _textController.text = jsonPrettify(_textController.text);
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
