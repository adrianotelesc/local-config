import 'dart:convert';

import 'package:collection/collection.dart';
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
    _textController.addListener(_calculateMaxCharacters);
  }

  @override
  void dispose() {
    _textController.removeListener(_calculateMaxCharacters);
    _textController.dispose();
    super.dispose();
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
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: numLines.mapIndexed((index, value) {
                        final buffer = StringBuffer();
                        buffer.write(index + 1);
                        for (int i = 1; i < value; i++) {
                          buffer.writeln();
                        }
                        return Text(
                          buffer.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.7),
                        );
                      }).toList(),
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Save the width of the TextFormField from the constraints
                        textFieldWidth = constraints.maxWidth;

                        return TextFormField(
                          maxLines: null,
                          style: textStyle,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              border: InputBorder.none),
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<double> _calculateLineWidths(String text, BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(maxWidth: MediaQuery.sizeOf(context).width);

    List<double> lineWidths = [];
    final lineCount = textPainter.computeLineMetrics().length;
    for (int i = 0; i < lineCount; i++) {
      final line = textPainter.computeLineMetrics()[i];
      lineWidths.add(line.width);
    }
    return lineWidths;
  }

  void _calculateMaxCharacters() {
    final lineWidths = _calculateLineWidths(_textController.text, context);

    setState(() {
      numLines = lineWidths.map<int>(
        (width) {
          return width <= textFieldWidth ? 1 : (width / textFieldWidth).ceil();
        },
      ).toList();
    });
    print(lineWidths);
    print(numLines);
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
