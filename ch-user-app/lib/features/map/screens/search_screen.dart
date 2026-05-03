import 'package:flutter/material.dart';
import 'package:corfu_shared/shared.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<PlaceEntity> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = context.read<AppRepository>();
      final results = await repo.searchPlaces(query.trim());
      setState(() => _results = results);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search places…',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: _search,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'Search for restaurants, beaches, landmarks…',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) {
                    final p = _results[i];
                    return ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(p.name),
                      subtitle: p.address != null ? Text(p.address!) : null,
                      onTap: () => context.push('/place/${p.id}', extra: p),
                    );
                  },
                ),
    );
  }
}
