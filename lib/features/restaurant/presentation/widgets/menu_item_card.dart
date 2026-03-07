import 'package:flutter/material.dart';
import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';

class MenuItemCard extends StatelessWidget {
  final MenuEntity menu;

  const MenuItemCard({super.key, required this.menu});

  // Keep the normalization logic here to keep the main screen clean
  String? _normalizeImageUrl(String url) {
    if (url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    // Adjust this base URL to match your backend configuration
    return 'http://10.0.2.2:3000/$url'.replaceAll('\\', '/');
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = menu.isAvailable;
    final normalizedMenuImageUrl = _normalizeImageUrl(menu.imageUrl ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          SizedBox(
            height: 110,
            width: double.infinity,
            child: normalizedMenuImageUrl == null
                ? Image.asset('assets/images/chiya.png', fit: BoxFit.cover)
                : Image.network(
                    normalizedMenuImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/chiya.png',
                      fit: BoxFit.cover,
                    ),
                  ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        menu.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D223F),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildAvailabilityBadge(isAvailable),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  (menu.description?.trim().isNotEmpty == true)
                      ? menu.description!
                      : 'No description available',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5F6F85),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rs ${menu.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE7744F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFD7F2E1) : const Color(0xFFF3E4E0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Unavailable',
        style: TextStyle(
          color: isAvailable
              ? const Color(0xFF149F59)
              : const Color(0xFFC46547),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
