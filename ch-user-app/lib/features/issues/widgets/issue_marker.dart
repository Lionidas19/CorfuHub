import 'package:flutter/material.dart';
import 'package:corfu_shared/shared.dart';
import '../../../core/theme/app_theme.dart';

class IssueMarker extends StatelessWidget {
  final IssueEntity issue;
  final VoidCallback onTap;

  const IssueMarker({super.key, required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(issue.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
