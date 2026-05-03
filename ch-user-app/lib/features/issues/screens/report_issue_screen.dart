import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../issues_notifier.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  static const _corfuCenter = LatLng(39.6243, 19.9217);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  LatLng? _pinPoint;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pinPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap the map to place a pin first')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final notifier = context.read<IssuesNotifier>();
    final issue = await notifier.reportIssue(
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      lat: _pinPoint!.latitude,
      lng: _pinPoint!.longitude,
    );

    if (!mounted) return;
    if (issue != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue reported — thank you!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<IssuesNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Report an issue')),
      body: Column(
        children: [
          // Map pin picker
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _corfuCenter,
                    initialZoom: 13,
                    onTap: (_, latlng) => setState(() => _pinPoint = latlng),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.corfuhub.app',
                    ),
                    if (_pinPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pinPoint!,
                            width: 36,
                            height: 36,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_pinPoint == null)
                  const Center(
                    child: IgnorePointer(
                      child: Text(
                        'Tap to pin location',
                        style: TextStyle(
                          backgroundColor: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration:
                          const InputDecoration(labelText: 'Issue title *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    if (notifier.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(notifier.error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ),
                    FilledButton(
                      onPressed: notifier.submitting ? null : _submit,
                      child: notifier.submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit report'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
