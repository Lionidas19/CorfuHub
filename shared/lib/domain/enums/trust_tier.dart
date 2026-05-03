/// Trust tier levels for user reputation system
enum TrustTier {
  newcomer,
  contributor,
  regular,
  trusted,
  steward;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case TrustTier.newcomer:
        return 'Newcomer';
      case TrustTier.contributor:
        return 'Contributor';
      case TrustTier.regular:
        return 'Regular';
      case TrustTier.trusted:
        return 'Trusted';
      case TrustTier.steward:
        return 'Steward';
    }
  }

  /// Confidence weight multiplier for check-ins
  double get confidenceWeight {
    switch (this) {
      case TrustTier.newcomer:
        return 0.5;
      case TrustTier.contributor:
        return 0.75;
      case TrustTier.regular:
        return 1.0;
      case TrustTier.trusted:
        return 1.5;
      case TrustTier.steward:
        return 2.0;
    }
  }

  /// Short description of this tier
  String get description {
    switch (this) {
      case TrustTier.newcomer:
        return 'Just getting started';
      case TrustTier.contributor:
        return 'Proven contributor';
      case TrustTier.regular:
        return 'Trusted community member';
      case TrustTier.trusted:
        return 'High-quality contributor';
      case TrustTier.steward:
        return 'Community pillar';
    }
  }

  /// Parse from string (for DB deserialization)
  static TrustTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'newcomer':
        return TrustTier.newcomer;
      case 'contributor':
        return TrustTier.contributor;
      case 'regular':
        return TrustTier.regular;
      case 'trusted':
        return TrustTier.trusted;
      case 'steward':
        return TrustTier.steward;
      default:
        return TrustTier.newcomer; // Default fallback
    }
  }

  /// Convert to string for DB serialization
  String toDbString() {
    return name;
  }
}
