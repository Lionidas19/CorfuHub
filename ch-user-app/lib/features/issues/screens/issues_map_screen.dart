import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../issues_notifier.dart';
import '../widgets/issue_marker.dart';

class IssuesMapScreen extends StatefulWidget {
  const IssuesMapScreen({super.key});

  @override
  State<IssuesMapScreen> createState() => _IssuesMapScreenState();
}

class _IssuesMapScreenState extends State<IssuesMapScreen> {
  static const _corfuCenter = LatLng(39.6243, 19.9217);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IssuesNotifier>().loadIssues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<IssuesNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issues map'),
        actions: [
          if (notifier.loading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _corfuCenter,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.corfuhub.app',
          ),
          MarkerLayer(
            markers: notifier.issues
                .where((i) => i.latitude != null && i.longitude != null)
                .map(
                  (i) => Marker(
                    point: LatLng(i.latitude!, i.longitude!),
                    width: 36,
                    height: 36,
                    child: IssueMarker(
                      issue: i,
                      onTap: () => context.push('/issues/${i.id}', extra: i),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/issues/report'),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Report'),
      ),
    );
  }
}
