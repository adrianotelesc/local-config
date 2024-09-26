import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class StringLocalConfigWidget extends StatefulWidget {
  const StringLocalConfigWidget({
    super.key,
    required this.name,
    required this.value,
  });

  final String name;
  final String value;

  @override
  State<StatefulWidget> createState() => _StringLocalConfigWidgetState();
}

class _StringLocalConfigWidgetState extends State<StringLocalConfigWidget> {
  String value = RemoteConfigValue.defaultValueForString;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.name),
          Text(value),
        ],
      ),
      onTap: () {
        showAdaptiveDialog(
          context: context,
          builder: (context) {
            return const Column(
              children: [
                TextField(),
              ],
            );
          },
        );
      },
    );
  }

  void onChanged(String value) {
    setState(() {
      this.value = value;
    });
  }
}
