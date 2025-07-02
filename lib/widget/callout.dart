import 'package:flutter/material.dart';
import 'package:local_config/custom_colors.dart';

enum _CalloutVariant { success, warning }

class CalloutStyle {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final int? cornerRadius;

  CalloutStyle({
    this.cornerRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });
}

class Callout extends StatelessWidget {
  final _CalloutVariant _variant;
  final CalloutStyle? style;
  final IconData? icon;
  final String text;
  final Widget? action;

  const Callout.warning({
    super.key,
    this.style,
    this.icon,
    required this.text,
    this.action,
  }) : _variant = _CalloutVariant.warning;

  const Callout.success({
    super.key,
    this.style,
    this.icon,
    required this.text,
    this.action,
  }) : _variant = _CalloutVariant.success;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>();
    final backgroundColor = _variant == _CalloutVariant.success
        ? style?.backgroundColor ?? customColors!.successContainer
        : style?.backgroundColor ?? customColors!.warningContainer;
    final foregroundColor = _variant == _CalloutVariant.success
        ? style?.foregroundColor ?? customColors!.success
        : style?.foregroundColor ?? customColors!.warning;
    final borderColor = _variant == _CalloutVariant.success
        ? style?.borderColor ?? customColors!.onSuccessContainer
        : style?.borderColor ?? customColors!.onWarningContainer;
    final borderRadius = style?.cornerRadius ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius.toDouble()),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: foregroundColor,
          ),
          const SizedBox.square(
            dimension: 8,
          ),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: foregroundColor),
          ),
          const Spacer(),
          action ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
