import 'package:firebase_local_config/local_config.dart';
import 'package:firebase_local_config/model/config_value.dart';
import 'package:flutter/material.dart';

class TextConfigWidget extends StatefulWidget {
  const TextConfigWidget({
    super.key,
    required this.configKey,
    required this.configValue,
  });

  final String configKey;
  final ConfigValue configValue;

  @override
  State<StatefulWidget> createState() => _TextConfigWidgetState();
}

class _TextConfigWidgetState extends State<TextConfigWidget> {
  final _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  String configValue = '';

  @override
  void initState() {
    super.initState();
    configValue = widget.configValue.value;
    controller.text = configValue;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        title: Text(widget.configKey),
        leading: widget.configValue.valueType == ConfigValueType.int ||
                widget.configValue.valueType == ConfigValueType.double
            ? const Icon(Icons.onetwothree)
            : const Icon(Icons.abc),
        trailing: Text(configValue.toString()),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(widget.configKey),
              content: Form(
                key: _formKey,
                child: TextFormField(
                  controller: controller,
                  autovalidateMode: AutovalidateMode.always,
                  validator: (textValue) {
                    if (widget.configValue.valueType == ConfigValueType.int &&
                        textValue != null &&
                        int.tryParse(textValue) == null) {
                      return 'int bruh';
                    }

                    if (widget.configValue.valueType ==
                            ConfigValueType.double &&
                        textValue != null &&
                        double.tryParse(textValue) == null) {
                      return 'double bruh';
                    }

                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    controller.text = configValue;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
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

  void onChanged(String value) {
    setState(() {
      configValue = value;
    });
    LocalConfig.instance.setString(widget.configKey, value);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
