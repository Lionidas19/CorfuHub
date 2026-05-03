import 'package:flutter/material.dart';
import 'package:corfu_shared/shared.dart';

class PlaceMarker extends StatelessWidget {
  final PlaceEntity place;
  final VoidCallback onTap;

  const PlaceMarker({super.key, required this.place, required this.onTap});

  Color get _color {
    if (!place.active) return Colors.grey;
    if (place.isFeatured) return const Color(0xFF1A73E8);
    return const Color(0xFF00897B);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.place, color: Colors.white, size: 22),
      ),
    );
  }
}
