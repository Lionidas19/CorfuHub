import 'package:flutter/material.dart';
import 'package:corfu_shared/enums.dart';

/// Displays a trust tier badge with consistent styling
class TierBadgeWidget extends StatelessWidget {
  final TrustTier tier;
  final bool showLabel;
  final double size;

  const TierBadgeWidget({
    super.key,
    required this.tier,
    this.showLabel = true,
    this.size = 24,
  });

  Color get _badgeColor {
    switch (tier) {
      case TrustTier.newcomer:
        return Colors.grey.shade400;
      case TrustTier.contributor:
        return Colors.brown.shade400;
      case TrustTier.regular:
        return Colors.grey.shade300;
      case TrustTier.trusted:
        return Colors.amber.shade600;
      case TrustTier.steward:
        return Colors.purple.shade400;
    }
  }

  IconData get _badgeIcon {
    switch (tier) {
      case TrustTier.newcomer:
        return Icons.shield_outlined;
      case TrustTier.contributor:
        return Icons.shield;
      case TrustTier.regular:
        return Icons.shield;
      case TrustTier.trusted:
        return Icons.shield;
      case TrustTier.steward:
        return Icons.military_tech; // Star shield
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      // Icon only mode
      return Icon(
        _badgeIcon,
        color: _badgeColor,
        size: size,
      );
    }

    // Full badge with label
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.15),
        border: Border.all(color: _badgeColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_badgeIcon, color: _badgeColor, size: size * 0.8),
          const SizedBox(width: 6),
          Text(
            tier.displayName,
            style: TextStyle(
              color: _badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: size * 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
