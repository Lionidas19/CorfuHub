import 'package:flutter/material.dart';
import 'enums.dart';

/// Wraps any widget tree with a visible environment badge in non-production builds.
///
/// Usage (in your host app's main widget):
/// ```dart
/// EnvBanner(
///   environment: EnvironmentEnum.fromValue(const String.fromEnvironment('ENV')),
///   child: MyApp(),
/// )
/// ```
class EnvBanner extends StatelessWidget {
  final Widget child;
  final EnvironmentEnum environment;

  const EnvBanner({
    super.key,
    required this.child,
    required this.environment,
  });

  Color get _color {
    switch (environment) {
      case EnvironmentEnum.local:
        return Colors.green.shade400;
      case EnvironmentEnum.staging:
        return Colors.amber.shade400;
      case EnvironmentEnum.production:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (environment.isProduction) return child;

    return Stack(
      children: [
        child,
        Positioned(
          top: 8,
          right: 8,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.92),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                environment.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
