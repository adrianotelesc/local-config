import 'package:flutter/material.dart';

class ExtendedListTile extends StatelessWidget {
  final Widget? top;

  final ExtendedListTileStyle? style;

  final Widget? leading;

  final Widget? title;

  final Widget? subtitle;

  final Widget? trailing;

  const ExtendedListTile({
    super.key,
    this.top,
    this.style,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = style?.tileColor;

    return Container(
      color: tileColor,
      child: Column(
        children: [
          if (top != null)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: top,
            ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: leading,
            title: title,
            titleTextStyle: style?.titleTextStyle,
            subtitle: subtitle,
            subtitleTextStyle: style?.subtitleTextStyle,
            trailing: trailing,
          ),
        ],
      ),
    );
  }
}

class ExtendedListTileStyle {
  final Color? tileColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;

  const ExtendedListTileStyle({
    this.tileColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
  });
}
