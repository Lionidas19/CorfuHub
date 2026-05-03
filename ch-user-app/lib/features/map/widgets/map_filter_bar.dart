import 'package:flutter/material.dart';

const _categories = [
  ('restaurant', 'Restaurants', Icons.restaurant),
  ('beach', 'Beaches', Icons.beach_access),
  ('landmark', 'Landmarks', Icons.account_balance),
  ('shop', 'Shops', Icons.shopping_bag_outlined),
  ('hotel', 'Hotels', Icons.hotel),
  ('bar', 'Bars', Icons.local_bar_outlined),
];

class MapFilterBar extends StatelessWidget {
  final String? activeCategory;
  final ValueChanged<String?> onSelect;

  const MapFilterBar({
    super.key,
    required this.activeCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _Chip(
            label: 'All',
            icon: Icons.layers_outlined,
            selected: activeCategory == null,
            onTap: () => onSelect(null),
          ),
          for (final (id, label, icon) in _categories)
            _Chip(
              label: label,
              icon: icon,
              selected: activeCategory == id,
              onTap: () => onSelect(activeCategory == id ? null : id),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        avatar: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onSelected: (_) => onTap(),
        selectedColor: cs.primaryContainer,
        checkmarkColor: cs.primary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
