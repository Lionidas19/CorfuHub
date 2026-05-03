import 'package:flutter/material.dart';
import 'package:corfu_shared/shared.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../map_notifier.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  final PlaceEntity? place;

  const PlaceDetailScreen({super.key, required this.placeId, this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  PlaceEntity? _place;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _place = widget.place;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final n = context.read<MapNotifier>();
      n.loadEventsForPlace(widget.placeId);
      n.loadJobsForPlace(widget.placeId);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MapNotifier>();
    final place = _place;

    return Scaffold(
      appBar: AppBar(
        title: Text(place?.name ?? 'Place'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Events'),
            Tab(text: 'Jobs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // -- INFO TAB --
          _InfoTab(place: place),

          // -- EVENTS TAB --
          notifier.events.isEmpty
              ? const Center(child: Text('No upcoming events'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifier.events.length,
                  itemBuilder: (_, i) {
                    final ev = notifier.events[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(ev.title),
                        subtitle: ev.startsAt != null
                            ? Text(_formatDate(ev.startsAt!))
                            : null,
                      ),
                    );
                  },
                ),

          // -- JOBS TAB --
          notifier.jobs.isEmpty
              ? const Center(child: Text('No job postings'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifier.jobs.length,
                  itemBuilder: (_, i) {
                    final job = notifier.jobs[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.work_outline),
                        title: Text(job.title),
                        subtitle: job.description != null
                            ? Text(
                                job.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/check-ins/confirm',
            extra: {'placeId': widget.placeId, 'placeName': place?.name}),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Check in'),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoTab extends StatelessWidget {
  final PlaceEntity? place;
  const _InfoTab({this.place});

  @override
  Widget build(BuildContext context) {
    if (place == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (place!.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              place!.imageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        const SizedBox(height: 16),
        if (place!.description != null)
          Text(place!.description!,
              style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        if (place!.address != null)
          _InfoRow(icon: Icons.location_on_outlined, text: place!.address!),
        if (place!.phone != null)
          _InfoRow(icon: Icons.phone_outlined, text: place!.phone!),
        if (place!.website != null)
          _InfoRow(icon: Icons.language, text: place!.website!),
        if (place!.hours != null)
          _InfoRow(icon: Icons.access_time, text: place!.hours!),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
