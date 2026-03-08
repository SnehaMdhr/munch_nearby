import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/core/utils/snackbar_utils.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/auth/presentation/widgets/my_text_form_field.dart';
import 'package:munch_nearby/features/favourite/domain/entities/favourite_entity.dart';
import 'package:munch_nearby/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';
import 'package:munch_nearby/features/menu/presentation/state/menu_state.dart';
import 'package:munch_nearby/features/menu/presentation/view_model/menu_view_model.dart';
import 'package:munch_nearby/features/restaurant/presentation/view_model/restaurant_view_model.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/favourite_toggle_button.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/menu_item_card.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/menu_section.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/review_section.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/tab_button.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/review/presentation/state/review_state.dart';
import 'package:munch_nearby/features/review/presentation/view_model/review_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  StreamSubscription<GyroscopeEvent>? _gyroscpoeEventSubscription;
  bool _sensorTriggered = false;
  bool isMenuSelected = true;

  // Some devices report proximity as binary (0/1), others as distance values.
  // Treat only 0 or 1 as "near" for binary sensors and small positive values
  // as near for distance-based sensors.
  bool _isNearFromSensorValue(int event) {
    if (event == 0 || event == 1) {
      return event == 0;
    }
    return event > 0 && event < 4;
  }

  void _startGyroscopeSensor() {
    _gyroscpoeEventSubscription = gyroscopeEvents.listen((event) async {
      final authState = ref.read(authViewModelProvider);
      final customerId = authState.authEntity?.userId;

      if (customerId == null) return;

      final favouriteNotifier = ref.read(favouriteViewModelProvider.notifier);

      final entity = FavouriteEntity(
        customerId: customerId,
        restaurantId: widget.restaurantId,
      );

      /// TILT RIGHT ADD TO FAVOURITE
      if (event.y > 2 && !_sensorTriggered) {
        _sensorTriggered = true;

        await favouriteNotifier.toggleFavourite(entity);
        await favouriteNotifier.loadFavourites();

        if (!mounted) return;
        SnackbarUtils.showInfo(context, "Tilt Right -> Added to favourites");
      }

      /// TILT LEFT REMOVE FROM FAVOURITE
      if (event.y < -2 && !_sensorTriggered) {
        _sensorTriggered = true;

        await favouriteNotifier.removeFromFavourite(widget.restaurantId);

        if (!mounted) return;

        SnackbarUtils.showInfo(context, "Tilt Left -> Removed from favourites");
      }

      /// RESET SENSOR
      if (event.y.abs() < 0.5) {
        _sensorTriggered = false;
      }
    });
  }

  @override
  void dispose() {
    _gyroscpoeEventSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(menuViewModelProvider.notifier).fetchMenus(widget.restaurantId);
      ref
          .read(reviewViewModelProvider.notifier)
          .loadRestaurantReviews(widget.restaurantId);
    });
    _startGyroscopeSensor();
  }

  String? _normalizeMenuImageUrl(String rawUrl) {
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

  DateTime? _dateFromMongoObjectId(String? objectId) {
    if (objectId == null || objectId.length < 8) return null;
    final hex = objectId.substring(0, 8);
    final seconds = int.tryParse(hex, radix: 16);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    ).toLocal();
  }

  String _formatPostedDate(DateTime? date, {String? reviewId}) {
    final resolvedDate = date ?? _dateFromMongoObjectId(reviewId);
    if (resolvedDate == null) return 'POSTED ON --';

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    final month = months[resolvedDate.month - 1];
    return 'POSTED ON $month ${resolvedDate.day}, ${resolvedDate.year}';
  }

  void _openReviewSheet({ReviewEntity? existingReview}) {
    final isEditing = existingReview != null;
    final commentController = TextEditingController(
      text: isEditing ? existingReview.comment : "",
    );
    int selectedRating = isEditing ? existingReview.rating : 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? "Edit Your Review" : "Write a Review",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () =>
                          setModalState(() => selectedRating = index + 1),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 15),
              MyTextFormField(
                controller: commentController,
                label: "Share your experience...",
                onChanged: (String value) {},
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (commentController.text.trim().length < 5) {
                      SnackbarUtils.showInfo(
                        context,
                        "Min 5 characters required",
                      );
                      return;
                    }

                    final reviewData = ReviewEntity(
                      customerId: existingReview?.customerId ?? '',
                      restaurantId: widget.restaurantId,
                      rating: selectedRating,
                      comment: commentController.text.trim(),
                    );

                    if (isEditing) {
                      ref
                          .read(reviewViewModelProvider.notifier)
                          .updateReview(existingReview.reviewId!, reviewData);
                    } else {
                      ref
                          .read(reviewViewModelProvider.notifier)
                          .addReview(reviewData);
                    }

                    Navigator.pop(context);
                  },

                  child: Ink(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isEditing
                            ? const [Color(0xFFE87A5D), Color(0xFFF6B88F)]
                            : const [Color(0xFFE87A5D), Color(0xFFF6B88F)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isEditing ? "Update Review" : "Submit Review",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(reviewViewModelProvider.notifier)
                  .deleteReview(reviewId, widget.restaurantId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Map<String, List<MenuEntity>> _groupByCategory(List<MenuEntity> menus) {
    final Map<String, List<MenuEntity>> map = {};
    for (var menu in menus) {
      if (!map.containsKey(menu.category)) {
        map[menu.category] = [];
      }
      map[menu.category]!.add(menu);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final restaurantState = ref.watch(restaurantViewModelProvider);
    final restaurant = restaurantState.restaurants
        .where((r) => r.id == widget.restaurantId)
        .firstOrNull;

    if (restaurant == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final menuState = ref.watch(menuViewModelProvider);
    final reviewState = ref.watch(reviewViewModelProvider);
    final reviewCount = reviewState.reviews.length;
    final averageRating = reviewCount == 0
        ? 0.0
        : reviewState.reviews
                  .map((review) => review.rating)
                  .reduce((a, b) => a + b) /
              reviewCount;

    final roundedRating = averageRating.toStringAsFixed(1);
    final currentUserId = ref
        .watch(userSessionServiceProvider)
        .getCurrentUserId();
    final normalizedImageUrl = _normalizeMenuImageUrl(
      restaurant.imageUrl ?? '',
    );

    final favouriteState = ref.watch(favouriteViewModelProvider);
    final isFavourite = favouriteState.favourites.any(
      (item) => item.restaurantId == widget.restaurantId,
    );

    const Color brandPeach = Color(0xFFE98869);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: !isMenuSelected
          ? FloatingActionButton(
              onPressed: () => _openReviewSheet(),
              backgroundColor: brandPeach,
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          // 1. Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: normalizedImageUrl == null
                ? Image.asset('assets/images/chiya.png', fit: BoxFit.cover)
                : Image.network(
                    normalizedImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/chiya.png',
                      fit: BoxFit.cover,
                    ),
                  ),
          ),

          // 2. Custom App Bar Icons
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FavouriteToggleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                GestureDetector(
                  onTap: () async {
                    final authState = ref.read(authViewModelProvider);
                    final customerId = authState.authEntity?.userId;

                    if (customerId == null) {
                      SnackbarUtils.showError(context, "Please Login first");
                      return;
                    }

                    final entity = FavouriteEntity(
                      customerId: customerId,
                      restaurantId: widget.restaurantId,
                    );

                    final favouriteNotifier = ref.read(
                      favouriteViewModelProvider.notifier,
                    );
                    await favouriteNotifier.toggleFavourite(entity);
                    await favouriteNotifier.loadFavourites();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavourite ? Icons.favorite : Icons.favorite_border,
                      color: isFavourite ? Colors.red : Colors.black,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Main Content Card
          Positioned.fill(
            top: 260,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final filled = averageRating >= index + 1;
                          return Icon(
                            filled ? Icons.star : Icons.star_border,
                            size: 22,
                            color: const Color(0xFFF5B301),
                          );
                        }),
                        const SizedBox(width: 10),
                        Text(
                          roundedRating,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2A44),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '($reviewCount reviews)',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E97A8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEE5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        restaurant.category?.trim().isNotEmpty == true
                            ? restaurant.category!
                            : 'General',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDE7A4A),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 24,
                          color: Color(0xFF7E889B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            restaurant.address,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF5E6A7D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (restaurant.contactNumber.trim().isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 24,
                            color: Color(0xFF7E889B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            restaurant.contactNumber,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF5E6A7D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    if (restaurant.description?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 18),
                      Text(
                        restaurant.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4C586E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3F0),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          TabButton(
                            title: "Menu",
                            isActive: isMenuSelected,
                            onTap: () => setState(() => isMenuSelected = true),
                          ),
                          TabButton(
                            title: "Reviews",
                            isActive: !isMenuSelected,
                            onTap: () => setState(() => isMenuSelected = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Switchable Content
                    isMenuSelected
                        ? MenuSection(
                            state: menuState,
                            menuItemBuilder: (menu) => MenuItemCard(menu: menu),
                          )
                        : ReviewSection(
                            state: reviewState,
                            currentUserId: currentUserId,
                            onEdit: (rev) =>
                                _openReviewSheet(existingReview: rev),
                            onDelete: (id) => _confirmDelete(id),
                            normalizeImageUrl: (url) =>
                                _normalizeMenuImageUrl(url),
                            formatDate: (date, {reviewId}) =>
                                _formatPostedDate(date, reviewId: reviewId),
                          ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
