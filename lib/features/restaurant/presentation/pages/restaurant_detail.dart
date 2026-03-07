import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/api/api_endpoints.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:munch_nearby/features/favourite/domain/entities/favourite_entity.dart';
import 'package:munch_nearby/features/favourite/presentation/view_model/favourite_view_model.dart';
import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';
import 'package:munch_nearby/features/menu/presentation/state/menu_state.dart';
import 'package:munch_nearby/features/menu/presentation/view_model/menu_view_model.dart';
import 'package:munch_nearby/features/restaurant/presentation/view_model/restaurant_view_model.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/review/presentation/state/review_state.dart';
import 'package:munch_nearby/features/review/presentation/view_model/review_view_model.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  bool isMenuSelected = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(menuViewModelProvider.notifier).fetchMenus(widget.restaurantId);
      ref
          .read(reviewViewModelProvider.notifier)
          .loadRestaurantReviews(widget.restaurantId);
    });
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
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Share your experience...",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isEditing ? Colors.blue : const Color(0xFFE98869),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (commentController.text.trim().length < 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Min 5 characters required"),
                        ),
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
                _buildCircularButton(
                  Icons.arrow_back,
                  () => Navigator.pop(context),
                ),
                GestureDetector(
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
                          _buildTabButton(
                            "Menu",
                            isMenuSelected,
                            () => setState(() => isMenuSelected = true),
                          ),
                          _buildTabButton(
                            "Reviews",
                            !isMenuSelected,
                            () => setState(() => isMenuSelected = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Switchable Content
                    isMenuSelected
                        ? _buildMenuSection(menuState)
                        : _buildReviewsSection(reviewState, currentUserId),

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

  Widget _buildCircularButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE98869) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(MenuState state) {
    if (state.status == MenuStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.menus.isEmpty) {
      return const Center(child: Text("No items available."));
    }

    final groupedMenus = _groupByCategory(state.menus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedMenus.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...entry.value.map((menu) => _buildMenuItemCard(menu)),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMenuItemCard(MenuEntity menu) {
    final isAvailable = menu.isAvailable;
    final normalizedMenuImageUrl = _normalizeMenuImageUrl(menu.imageUrl ?? '');

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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFFD7F2E1)
                            : const Color(0xFFF3E4E0),
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
                    ),
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

  Widget _buildReviewsSection(ReviewState state, String? currentUserId) {
    if (state.status == ReviewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.reviews.isEmpty) {
      return const Center(child: Text("No reviews yet."));
    }

    return Column(
      children: state.reviews.map((review) {
        final bool isMyReview = review.customerId == currentUserId;
        final reviewerName = review.customerName?.trim().isNotEmpty == true
            ? review.customerName!
            : 'Guest';
        final reviewerImageUrl = _normalizeMenuImageUrl(
          review.customerImageUrl ?? '',
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Top Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar image
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: reviewerImageUrl == null
                        ? null
                        : NetworkImage(reviewerImageUrl),
                    child: reviewerImageUrl == null
                        ? Text(
                            reviewerName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Name
                  Expanded(
                    child: Text(
                      isMyReview ? 'You' : reviewerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2A44),
                      ),
                    ),
                  ),

                  // ⭐ Rating badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFFFD8C4)),
                    ),
                    child: Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 18,
                          color: const Color(0xFFE7744F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ✨ Review text
              Text(
                '"${review.comment}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  color: Color(0xFF4C586E),
                ),
              ),

              const SizedBox(height: 22),

              const Divider(),

              const SizedBox(height: 10),

              // 📅 Date
              Text(
                _formatPostedDate(review.createdAt, reviewId: review.reviewId),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Color(0xFF8E97A8),
                ),
              ),

              // Edit/Delete for my review
              if (isMyReview)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.blue,
                        ),
                        onPressed: () =>
                            _openReviewSheet(existingReview: review),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () => _confirmDelete(review.reviewId!),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
