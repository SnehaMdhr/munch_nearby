import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/app/routes/app_routes.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/utils/snackbar_utils.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/favourite/domain/entities/favourite_entity.dart';
import 'package:munch_nearby/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:munch_nearby/features/map/presentation/pages/map_screen.dart';
import 'package:munch_nearby/features/restaurant/presentation/pages/restaurant_detail_screen.dart';

class RestaurantCard extends StatelessWidget {
  final String restaurantId;
  final String imageUrl;
  final String name;
  final String address;
  final String mapLink;
  final String description;
  final String category;
  final String contactNumber;
  final double? latitude;
  final double? longitude;
  final List? openingHours;

  const RestaurantCard({
    super.key,
    required this.restaurantId,
    required this.imageUrl,
    required this.name,
    required this.address,
    required this.mapLink,
    required this.description,
    required this.category,
    required this.contactNumber,
    this.latitude,
    this.longitude,
    this.openingHours,
  });

  String? _normalizeRestaurantImageUrl(String rawUrl) {
    if (rawUrl.trim().isEmpty || rawUrl.trim().toLowerCase() == 'null') {
      return null;
    }

    final value = rawUrl.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final baseUri = Uri.parse(ApiEndpoints.baseUrl);
    final origin = '${baseUri.scheme}://${baseUri.authority}';

    if (value.startsWith('/')) {
      return '$origin$value';
    }

    if (value.startsWith('uploads/')) {
      return '$origin/$value';
    }

    return '$origin/uploads/$value';
  }

  String _getStatus() {
    final hours = openingHours;
    if (hours == null || hours.isEmpty) return "Closed";

    final now = DateTime.now();
    final dayName = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ][now.weekday - 1];

    final today = hours.cast<Map<String, dynamic>>().firstWhere(
      (d) => d['day'] == dayName,
      orElse: () => <String, dynamic>{},
    );

    if (today.isEmpty ||
        today['isClosed'] == true ||
        today['open'] == null ||
        today['close'] == null) {
      return "Closed";
    }

    final int currentMinutes = now.hour * 60 + now.minute;

    final openSplit = today['open'].toString().split(":");
    final closeSplit = today['close'].toString().split(":");

    int openMinutes = int.parse(openSplit[0]) * 60 + int.parse(openSplit[1]);
    int closeMinutes = int.parse(closeSplit[0]) * 60 + int.parse(closeSplit[1]);

    if (closeMinutes <= openMinutes) {
      closeMinutes += 1440;
    }

    if (currentMinutes >= openMinutes && currentMinutes < closeMinutes) {
      return "Open";
    }

    return "Closed";
  }

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = _normalizeRestaurantImageUrl(imageUrl);
    final displayCategory = category.trim().isEmpty ? 'General' : category;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.network(
                  normalizedImageUrl ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Consumer(
                  builder: (context, ref, _) {
                    final favouriteState = ref.watch(
                      favouriteViewModelProvider,
                    );
                    final isFavourite = favouriteState.favourites.any(
                      (item) => item.restaurantId == restaurantId,
                    );

                    return GestureDetector(
                      onTap: () async {
                        final authState = ref.read(authViewModelProvider);
                        final customerId = authState.authEntity?.userId;

                        if (customerId == null) {
                          SnackbarUtils.showInfo(context, "Please Login First");
                          return;
                        }

                        final entity = FavouriteEntity(
                          customerId: customerId,
                          restaurantId: restaurantId,
                        );

                        final favouriteNotifier = ref.read(
                          favouriteViewModelProvider.notifier,
                        );

                        await favouriteNotifier.toggleFavourite(entity);
                        await favouriteNotifier.loadFavourites();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: isFavourite
                              ? Colors.red
                              : const Color(0xFFD6D6D6),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEE5),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        displayCategory,
                        style: const TextStyle(
                          color: Color(0xFFDE7A4A),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF8D96A5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF5E6A7D),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Builder(
                  builder: (context) {
                    final status = _getStatus();
                    final isOpen = status == "Open";
                    return Text(
                      status,
                      style: TextStyle(
                        color: isOpen ? const Color(0xFF08A11A) : Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          AppRoutes.push(
                            context,
                            MapScreen(initialRestaurantId: restaurantId),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 40),
                          fixedSize: const Size.fromHeight(40),
                          side: const BorderSide(color: Color(0xFFD3D8E2)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: Color(0xFF445064),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Map',
                              style: TextStyle(
                                color: Color(0xFF445064),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          AppRoutes.push(
                            context,
                            RestaurantDetailScreen(restaurantId: restaurantId),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: SizedBox(
                          height: 40,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE87A5D), Color(0xFFF6B88F)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
