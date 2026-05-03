import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckInConfirmScreen extends StatelessWidget {
  final String? placeId;
  final String? placeName;

  const CheckInConfirmScreen({super.key, this.placeId, this.placeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check in')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Check in at\n${placeName ?? 'this place'}?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Checked in!')),
                );
                context.pop();
              },
              child: const Text('Confirm check-in'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
