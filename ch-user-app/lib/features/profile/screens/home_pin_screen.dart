import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

class HomePinScreen extends StatefulWidget {
  const HomePinScreen({super.key});

  @override
  State<HomePinScreen> createState() => _HomePinScreenState();
}

class _HomePinScreenState extends State<HomePinScreen> {
  static const _corfuCenter = LatLng(39.6243, 19.9217);
  LatLng? _pin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set home pin'),
        actions: [
          if (_pin != null)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Home pin saved')),
                );
                context.pop();
              },
              child: const Text('Save'),
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _corfuCenter,
          initialZoom: 13,
          onTap: (_, latlng) => setState(() => _pin = latlng),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.corfuhub.app',
          ),
          if (_pin != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _pin!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.pin_drop,
                    color: Colors.deepPurple,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
