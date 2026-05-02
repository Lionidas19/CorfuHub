import 'package:flutter/material.dart';
import 'package:corfu_shared/shared.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EnvBanner(
      child: MaterialApp(
        home: Scaffold(
          body: Center(child: Text('CH Owner App stub')),
        ),
      ),
    );
  }
}
