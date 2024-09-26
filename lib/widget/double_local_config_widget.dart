import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class DoubleLocalConfigWidget extends StatefulWidget {
  const DoubleLocalConfigWidget({
    super.key,
    required this.name,
    required this.value,
  });

  final String name;
  final double value;

  @override
  State<StatefulWidget> createState() => _DoubleLocalConfigWidgetState();
}

class _DoubleLocalConfigWidgetState extends State<DoubleLocalConfigWidget> {
  double value = RemoteConfigValue.defaultValueForDouble;

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

  void onChanged(double value) {
    setState(() {
      this.value = value;
    });
  }
}
