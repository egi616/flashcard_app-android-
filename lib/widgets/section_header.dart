import 'package:flutter/material.dart';

import '../theme/app_color.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, required this.trailing, super.key});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColor.textPrimary,
              ),
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }
}
