import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/app/routes/app_routes.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/favourite/domain/entities/favourite_entity.dart';
import 'package:munch_nearby/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:munch_nearby/features/menu/presentation/pages/menu_screen.dart';
import 'package:munch_nearby/features/review/presentation/pages/review_screen.dart';

class RestaurantCard extends StatelessWidget {
  final String restaurantId;
  final String imageUrl;
  final String name;
  final String address;
  final String mapLink;
  final String description;
  final String category;

  const RestaurantCard({
    super.key,
    required this.restaurantId,
    required this.imageUrl,
    required this.name,
    required this.address,
    required this.mapLink,
    required this.description,
    required this.category,
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

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = _normalizeRestaurantImageUrl(imageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  top: Radius.circular(16),
                ),
                child: normalizedImageUrl == null
                    ? Image.asset(
                        'assets/images/chiya.png',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        normalizedImageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/chiya.png',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please login first")),
                          );
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
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: isFavourite ? Colors.red : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// Category
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                /// Address
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// Description
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 14),

                /// Buttons Row
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Later use url_launcher to open mapLink
                        },
                        icon: const Icon(Icons.map),
                        label: const Text("View Map"),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AppRoutes.push(
                            context,
                            MenuScreen(
                              restaurantId: restaurantId,
                              restaurantName: name,
                            ),
                          );
                        },
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text("View Menu"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AppRoutes.push(
                        context,
                        ReviewScreen(
                          restaurantId: restaurantId,
                          restaurantName: name,
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review, color: Colors.white),
                    label: const Text(
                      "View Reviews",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
