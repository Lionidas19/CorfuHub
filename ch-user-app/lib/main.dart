import 'package:flutter/material.dart';

void main() {
  runApp(const CorfuHubApp());
}

class CorfuHubApp extends StatelessWidget {
  const CorfuHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CorfuHub',
      home: Scaffold(
        appBar: AppBar(title: const Text('CorfuHub')),
        body: const Center(child: Text('Welcome to CorfuHub (Resident App)')),
      ),
    );
  }
}
