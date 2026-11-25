import 'package:flutter/material.dart';

import '../theme/app_color.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
    this.secondary = false,
    this.warning = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool secondary;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final style = warning
        ? OutlinedButton.styleFrom(
            foregroundColor: AppColor.warningText,
            backgroundColor: const Color(0xFFFFFBEB),
            side: const BorderSide(color: AppColor.warningAmber),
            minimumSize: const Size(140, 50),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          )
        : null;
    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    final Widget button = secondary || warning
        ? OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: content,
          )
        : FilledButton(onPressed: onPressed, child: content);

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
