import 'package:firebase_local_config/local_config.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class TextConfigWidget extends StatefulWidget {
  const TextConfigWidget({
    super.key,
    required this.configKey,
    required this.configValue,
  });

  final String configKey;
  final String configValue;

  @override
  State<StatefulWidget> createState() => _TextConfigWidgetState();
}

class _TextConfigWidgetState extends State<TextConfigWidget> {
  String value = RemoteConfigValue.defaultValueForString;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    value = widget.configValue;
    controller.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        title: Text(widget.configKey),
        leading: isNumeric(value)
            ? const Icon(Icons.onetwothree)
            : const Icon(Icons.abc),
        trailing: Text(value),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(widget.configKey),
              content: TextField(
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onChanged(controller.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool isNumeric(String source) => double.tryParse(source) != null;

  void onChanged(String value) {
    setState(() {
      this.value = value;
    });
    LocalConfig.instance.setString(widget.configKey, value);
  }
}
