import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:corfu_shared/enums.dart';

const _testUsers = [
  (
    id: '00000000-0000-0000-0000-000000000001',
    name: 'Dev Admin',
    phone: '+306900000001',
    role: 'admin',
    tier: TrustTier.steward,
    icon: Icons.admin_panel_settings,
    color: Colors.purple,
  ),
  (
    id: '00000000-0000-0000-0000-000000000002',
    name: 'Dev Owner',
    phone: '+306900000002',
    role: 'owner',
    tier: TrustTier.trusted,
    icon: Icons.business_center,
    color: Colors.orange,
  ),
  (
    id: '00000000-0000-0000-0000-000000000003',
    name: 'Dev Resident',
    phone: '+306900000003',
    role: 'resident',
    tier: TrustTier.regular,
    icon: Icons.person,
    color: Colors.blue,
  ),
  (
    id: '00000000-0000-0000-0000-000000000004',
    name: 'New User',
    phone: '+306900000004',
    role: 'resident',
    tier: TrustTier.newcomer,
    icon: Icons.person_outline,
    color: Colors.grey,
  ),
  (
    id: '00000000-0000-0000-0000-000000000005',
    name: 'Active User',
    phone: '+306900000005',
    role: 'resident',
    tier: TrustTier.contributor,
    icon: Icons.person,
    color: Colors.green,
  ),
];

class DebugUserPickerScreen extends StatelessWidget {
  const DebugUserPickerScreen({super.key});

  Future<void> _signInAs(BuildContext context, String userId) async {
    final notifier = context.read<AuthNotifier>();
    await notifier.debugSignIn(userId);
    if (!context.mounted) return;
    if (notifier.isAuthenticated) {
      context.go('/map');
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthNotifier>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bug_report,
                        size: 16, color: Colors.orange.shade900),
                    const SizedBox(width: 6),
                    Text(
                      'DEBUG MODE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sign in as test user',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a user to test the app with different roles.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.separated(
                  itemCount: _testUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final user = _testUsers[i];
                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: notifier.loading
                            ? null
                            : () => _signInAs(context, user.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    user.color.withValues(alpha: 0.15),
                                child: Icon(user.icon,
                                    color: user.color, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.role.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _TierBadge(tier: user.tier),
                                        const SizedBox(width: 8),
                                        Text(
                                          user.phone,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (notifier.loading)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (notifier.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(notifier.error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.push('/auth/phone'),
                icon: const Icon(Icons.phone_android),
                label: const Text('Use phone OTP instead'),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final TrustTier tier;

  const _TierBadge({required this.tier});

  Color get _color {
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

  IconData get _icon {
    switch (tier) {
      case TrustTier.newcomer:
        return Icons.shield_outlined;
      case TrustTier.contributor:
      case TrustTier.regular:
      case TrustTier.trusted:
        return Icons.shield;
      case TrustTier.steward:
        return Icons.military_tech;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        border: Border.all(color: _color, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: 12),
          const SizedBox(width: 4),
          Text(
            tier.displayName,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
