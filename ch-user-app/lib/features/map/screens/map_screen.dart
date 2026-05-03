import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../map_notifier.dart';
import '../widgets/place_marker.dart';
import '../widgets/map_filter_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _corfuCenter = LatLng(39.6243, 19.9217);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapNotifier>().loadPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MapNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CorfuHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search places',
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          MapFilterBar(
            activeCategory: notifier.activeCategoryFilter,
            onSelect: notifier.setCategoryFilter,
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _corfuCenter,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.corfuhub.app',
                    ),
                    MarkerLayer(
                      markers: notifier.places
                          .where(
                              (p) => p.latitude != null && p.longitude != null)
                          .map(
                            (p) => Marker(
                              point: LatLng(p.latitude!, p.longitude!),
                              width: 40,
                              height: 40,
                              child: PlaceMarker(
                                place: p,
                                onTap: () =>
                                    context.push('/place/${p.id}', extra: p),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                if (notifier.loading)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                if (notifier.error != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(notifier.error!),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/issues/report'),
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('Report issue'),
      ),
    );
  }
}
