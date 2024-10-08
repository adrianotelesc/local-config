import 'package:firebase_local_config/model/config_value.dart';
import 'package:firebase_local_config/widget/toggle_config_widget.dart';
import 'package:firebase_local_config/widget/data_object_config_widget.dart';
import 'package:firebase_local_config/widget/text_config_widget.dart';
import 'package:flutter/material.dart';

class LocalConfigScreen extends StatelessWidget {
  final List<MapEntry<String, ConfigValue>> configs;

  const LocalConfigScreen({
    super.key,
    required this.configs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Config')),
      body: ListView.builder(
        itemCount: configs.length,
        itemBuilder: (context, index) {
          final configEntry = configs[index];

          switch (configEntry.value.valueType) {
            case ConfigValueType.bool:
              return ToggleConfigWidget(
                configKey: configEntry.key,
                configValue: configEntry.value,
              );

            case ConfigValueType.string:
            case ConfigValueType.int:
            case ConfigValueType.double:
              return TextConfigWidget(
                configKey: configEntry.key,
                configValue: configEntry.value,
              );

            case ConfigValueType.json:
              return DataObjectConfigWidget(
                configKey: configEntry.key,
                configValue: configEntry.value,
              );
          }
        },
      ),
    );
  }
}
