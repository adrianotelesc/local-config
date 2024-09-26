import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class IntLocalConfigWidget extends StatefulWidget {
  const IntLocalConfigWidget({
    super.key,
    required this.name,
    required this.value,
  });

  final String name;
  final int value;

  @override
  State<StatefulWidget> createState() => _IntLocalConfigWidgetState();
}

class _IntLocalConfigWidgetState extends State<IntLocalConfigWidget> {
  int value = RemoteConfigValue.defaultValueForInt;

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
          Text(value.toString()),
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

  void onChanged(int value) {
    setState(() {
      this.value = value;
    });
  }
}
