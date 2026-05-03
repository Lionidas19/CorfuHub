import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corfu_shared/enums.dart';
import 'package:corfu_shared/domain/constants/trust_tier_privileges.dart';
import '../../auth/auth_notifier.dart';
import '../widgets/tier_badge_widget.dart';

class TrustInfoScreen extends StatelessWidget {
  const TrustInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final user = authNotifier.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trust Level')),
        body: const Center(child: Text('Please sign in')),
      );
    }

    final tier = user.trustTier;
    final privileges = TrustTierPrivileges.forTier(tier);
    final nextTier = privileges.nextTier;
    final requirements = privileges.advancementRequirements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust Level'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current tier display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Your Current Trust Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TierBadgeWidget(tier: tier, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    tier.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confidence weight: ${tier.confidenceWeight}×',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Anonymity reminder
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'You Are Anonymous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your identity is never shown publicly. Only your trust level badge may appear on your contributions. No usernames, no profiles, no followers.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Your allowances header
          const Text(
            'Your Allowances',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Rate limits
          _buildPrivilegeCard(
            icon: Icons.report_problem,
            title: 'Issue Reports',
            value: '${privileges.dailyIssueReports} per day',
          ),
          _buildPrivilegeCard(
            icon: Icons.check_circle,
            title: 'Check-ins',
            value: '${privileges.dailyCheckIns} per day',
          ),
          _buildPrivilegeCard(
            icon: Icons.place,
            title: 'Place Submissions',
            value: '${privileges.weeklyPlaceSubmissions} per week',
          ),
          _buildPrivilegeCard(
            icon: Icons.bookmark,
            title: 'Saved Places',
            value: privileges.maxSavedPlaces >= 999
                ? 'Unlimited'
                : 'Up to ${privileges.maxSavedPlaces}',
          ),
          _buildPrivilegeCard(
            icon: Icons.edit,
            title: 'Edit Window',
            value: privileges.editWindowMinutes == -1
                ? 'Unlimited'
                : privileges.editWindowMinutes == 0
                    ? 'No editing'
                    : '${privileges.editWindowMinutes} minutes',
          ),
          _buildPrivilegeCard(
            icon: Icons.notifications,
            title: 'Notification Radius',
            value: '${privileges.notificationRadiusKm} km',
          ),

          const SizedBox(height: 24),

          // Special abilities
          const Text(
            'Special Abilities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildAbilityCard(
            icon: Icons.event,
            title: 'Submit Events',
            enabled: privileges.canSubmitEvents,
            detail: privileges.instantEventPosts
                ? 'Posts instantly'
                : 'Requires review',
          ),
          _buildAbilityCard(
            icon: Icons.hexagon,
            title: 'Area-wide Issues (Polygons)',
            enabled: privileges.canSubmitPolygonIssues,
          ),
          _buildAbilityCard(
            icon: Icons.route,
            title: 'Route Issues (Polylines)',
            enabled: privileges.canSubmitPolylineIssues,
          ),
          _buildAbilityCard(
            icon: Icons.flag,
            title: 'Flag Content',
            enabled: privileges.canFlagContent,
          ),
          _buildAbilityCard(
            icon: Icons.merge,
            title: 'Suggest Issue Merges',
            enabled: privileges.canSuggestMerges,
          ),

          const SizedBox(height: 24),

          // Next tier info
          if (nextTier != null && requirements != null) ...[
            const Text(
              'Advancement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Next Level: ${nextTier.displayName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Requirements: $requirements',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (tier == TrustTier.steward) ...[
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events,
                        color: Colors.purple.shade700, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Maximum Trust Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You\'ve reached the highest community trust tier. Thank you for your contributions!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // How trust works
          ExpansionTile(
            title: const Text(
              'How Trust Levels Work',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoPoint(
                      'Trust affects weighting, not popularity',
                      'Higher tier check-ins count more toward issue confidence, but this is about quality, not fame.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoPoint(
                      'You can advance, but never fall below Newcomer',
                      'Trust can be earned through quality contributions. You start at a base floor and can grow from there.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoPoint(
                      'Enforcement is separate',
                      'Warnings and bans are temporary and don\'t permanently affect your trust level. After a ban expires, your tier is restored.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoPoint(
                      'Quality over quantity',
                      'Accurate reports, helpful check-ins, and approved submissions earn trust faster than spam.',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPrivilegeCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAbilityCard({
    required IconData icon,
    required String title,
    required bool enabled,
    String? detail,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? Colors.green.shade700 : Colors.grey.shade400,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: enabled ? Colors.black : Colors.grey.shade600,
          ),
        ),
        subtitle: detail != null
            ? Text(detail, style: const TextStyle(fontSize: 12))
            : null,
        trailing: Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          color: enabled ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
