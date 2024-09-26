import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class BoolLocalConfigWidget extends StatefulWidget {
  const BoolLocalConfigWidget({
    super.key,
    required this.name,
    required this.value,
  });

  final String name;
  final bool value;

  @override
  State<StatefulWidget> createState() => _BoolLocalConfigWidgetState();
}

class _BoolLocalConfigWidgetState extends State<BoolLocalConfigWidget> {
  bool value = RemoteConfigValue.defaultValueForBool;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.name),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        )
      ],
    );
  }

  void onChanged(bool value) {
    setState(() {
      this.value = value;
    });
  }
}
