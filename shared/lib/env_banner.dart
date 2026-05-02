import 'package:flutter/material.dart';

/// Simple environment banner wrapper.
/// Usage: wrap your top-level app widget with `EnvBanner(child: MyApp())`.
class EnvBanner extends StatelessWidget {
  final Widget child;
  const EnvBanner({super.key, required this.child});

  static String get env => const String.fromEnvironment('ENV', defaultValue: 'production');

  @override
  Widget build(BuildContext context) {
    if (env == 'production') return child;

    return Stack(
      children: [
        child,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(env.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
