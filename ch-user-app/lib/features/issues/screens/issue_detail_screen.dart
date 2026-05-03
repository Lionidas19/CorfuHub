import 'package:flutter/material.dart';
import 'package:corfu_shared/shared.dart';
import 'package:provider/provider.dart';
import '../issues_notifier.dart';
import '../../../core/theme/app_theme.dart';

class IssueDetailScreen extends StatefulWidget {
  final String issueId;
  final IssueEntity? issue;

  const IssueDetailScreen({super.key, required this.issueId, this.issue});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  bool _checkedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IssuesNotifier>().loadIssue(widget.issueId);
    });
  }

  Future<void> _checkIn() async {
    final ok = await context.read<IssuesNotifier>().checkIn(widget.issueId);
    if (ok && mounted) {
      setState(() => _checkedIn = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in recorded — thanks!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<IssuesNotifier>();
    final issue = notifier.selected ?? widget.issue;

    return Scaffold(
      appBar: AppBar(title: const Text('Issue detail')),
      body: issue == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.statusColor(issue.status)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.statusColor(issue.status)),
                      ),
                      child: Text(
                        (issue.status ?? 'unknown').toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.statusColor(issue.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.people_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${issue.confidence} confirmations',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(issue.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                if (issue.description != null) ...[
                  const SizedBox(height: 12),
                  Text(issue.description!,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
                if (issue.createdAt != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Reported on ${_fmt(issue.createdAt!)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 32),
                if (!_checkedIn && issue.status == 'open')
                  FilledButton.icon(
                    onPressed: _checkIn,
                    icon: const Icon(Icons.thumb_up_outlined),
                    label: const Text('Confirm this issue'),
                  )
                else if (_checkedIn)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('You confirmed this issue'),
                    ),
                  ),
              ],
            ),
    );
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}
