import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_notifier.dart';
import '../widgets/tier_badge_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar / user info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.phone ?? 'Resident',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.role.name ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        if (user != null)
                          TierBadgeWidget(tier: user.trustTier, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Menu items
          _MenuItem(
            icon: Icons.shield,
            label: 'Trust level & privileges',
            onTap: () => context.push('/profile/trust-info'),
          ),
          _MenuItem(
            icon: Icons.location_on_outlined,
            label: 'Set home pin',
            onTap: () => context.push('/profile/home-pin'),
          ),
          _MenuItem(
            icon: Icons.bookmark_outline,
            label: 'Saved places',
            onTap: () => context.push('/profile/saved'),
          ),
          _MenuItem(
            icon: Icons.history,
            label: 'Check-in history',
            onTap: () => context.push('/check-ins/history'),
          ),
          const Divider(height: 32),
          _MenuItem(
            icon: Icons.logout,
            label: 'Sign out',
            color: Theme.of(context).colorScheme.error,
            onTap: () async {
              await context.read<AuthNotifier>().signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: color != null ? TextStyle(color: color) : null),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
