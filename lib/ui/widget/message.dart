import 'package:flutter/material.dart';

// TODO: Find a better name.

class Message extends StatelessWidget {
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final Widget header;
  final Widget body;
  final Widget footer;

  const Message({
    super.key,
    this.padding = EdgeInsets.zero,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 16,
    this.header = const SizedBox.shrink(),
    this.body = const SizedBox.shrink(),
    this.footer = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing,
        children: [
          header,
          body,
          footer,
        ],
      ),
    );
  }
}
