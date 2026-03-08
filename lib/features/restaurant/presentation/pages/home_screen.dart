import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/app/routes/app_routes.dart';
import 'package:munch_nearby/core/utils/snackbar_utils.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:munch_nearby/features/restaurant/presentation/view_model/restaurant_view_model.dart';
import 'package:munch_nearby/features/restaurant/presentation/state/restaurant_state.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = "All";
  bool openNow = false;

  // SHAKE SENSOR VARIABLES
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  int _lastShakeTime = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(restaurantViewModelProvider.notifier).getRestaurants();
    });

    // Start listening to accelerometer
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _detectShake(event);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  // ================= SHAKE DETECTION =================
  void _detectShake(AccelerometerEvent event) {
    double acceleration =
        (event.x * event.x + event.y * event.y + event.z * event.z);

    if (acceleration > 200) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentTime - _lastShakeTime > 1500) {
        _lastShakeTime = currentTime;
        _openRandomRestaurant();
      }
    }
  }

  void _openRandomRestaurant() {
    final state = ref.read(restaurantViewModelProvider);

    if (state.restaurants.isEmpty) return;

    final random = Random();
    final restaurant =
        state.restaurants[random.nextInt(state.restaurants.length)];

    SnackbarUtils.showInfo(context, 'Try: ${restaurant.name}');

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      AppRoutes.push(
        context,
        Scaffold(
          appBar: AppBar(
            title: Text(
              restaurant.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Center(
            child: SizedBox(
              width: 320,
              height: 400,
              child: RestaurantCard(
                restaurantId: restaurant.id,
                imageUrl: restaurant.imageUrl ?? "",
                name: restaurant.name,
                address: restaurant.address,
                mapLink: restaurant.mapLink ?? "",
                description:
                    restaurant.description ?? "No description available",
                category: restaurant.category ?? "General",
                contactNumber: restaurant.contactNumber,
                latitude: restaurant.latitude,
                longitude: restaurant.longitude,
                openingHours: restaurant.openingHours,
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSearchBar(),
            ),

            if (state.status == RestaurantStatus.loaded) _buildFilters(state),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(restaurantViewModelProvider.notifier)
                      .getRestaurants();
                },
                child: _buildContent(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _buildSearchBar() {
    final themeBackground = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: themeBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: "Search restaurants...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  // ================= FILTER BAR =================
  Widget _buildFilters(RestaurantState state) {
    final theme = Theme.of(context);

    final categories = [
      "All",
      ...state.restaurants.map((e) => e.category ?? "General").toSet().toList(),
    ];

    return SizedBox(
      height: 36,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            label: "Open Now",
            icon: Icons.access_time,
            active: openNow,
            onTap: () {
              setState(() {
                openNow = !openNow;
              });
            },
          ),

          const SizedBox(width: 10),

          Container(width: 1, height: 22, color: theme.dividerColor),

          const SizedBox(width: 10),

          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _filterChip(
                label: cat,
                active: selectedCategory == cat,
                onTap: () {
                  setState(() {
                    selectedCategory = cat;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    IconData? icon,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE87A5D) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: active ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CONTENT =================
  Widget _buildContent(RestaurantState state) {
    switch (state.status) {
      case RestaurantStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case RestaurantStatus.error:
        return Center(
          child: Text(state.errorMessage ?? "Something went wrong"),
        );

      case RestaurantStatus.loaded:
        final filteredRestaurants = state.restaurants.where((restaurant) {
          final query = _searchController.text.toLowerCase();

          final matchesSearch =
              restaurant.name.toLowerCase().contains(query) ||
              restaurant.address.toLowerCase().contains(query) ||
              (restaurant.category ?? "").toLowerCase().contains(query);

          final matchesCategory =
              selectedCategory == "All" ||
              (restaurant.category ?? "") == selectedCategory;

          final status = getRestaurantStatus(
            restaurant.openingHours ?? [],
            DateTime.now(),
          );

          final matchesOpenNow =
              !openNow || status == "Open" || status.startsWith("Opens in");

          return matchesSearch && matchesCategory && matchesOpenNow;
        }).toList();

        if (filteredRestaurants.isEmpty) {
          return const Center(child: Text("No restaurants found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredRestaurants.length,
          itemBuilder: (context, index) {
            final restaurant = filteredRestaurants[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RestaurantCard(
                restaurantId: restaurant.id,
                imageUrl: restaurant.imageUrl ?? "",
                name: restaurant.name,
                address: restaurant.address,
                mapLink: restaurant.mapLink ?? "",
                description:
                    restaurant.description ?? "No description available",
                category: restaurant.category ?? "General",
                contactNumber: restaurant.contactNumber,
                latitude: restaurant.latitude,
                longitude: restaurant.longitude,
                openingHours: restaurant.openingHours,
              ),
            );
          },
        );

      default:
        return const SizedBox();
    }
  }

  // ================= OPEN STATUS LOGIC =================
  String getRestaurantStatus(List openingHours, DateTime now) {
    final dayName = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ][now.weekday - 1];

    final today = openingHours.firstWhere(
      (d) => d['day'] == dayName,
      orElse: () => null,
    );

    if (today == null ||
        today['isClosed'] == true ||
        today['open'] == null ||
        today['close'] == null) {
      return "Closed";
    }

    int currentMinutes = now.hour * 60 + now.minute;

    List openSplit = today['open'].split(":");
    List closeSplit = today['close'].split(":");

    int openMinutes = int.parse(openSplit[0]) * 60 + int.parse(openSplit[1]);
    int closeMinutes = int.parse(closeSplit[0]) * 60 + int.parse(closeSplit[1]);

    if (closeMinutes <= openMinutes) {
      closeMinutes += 1440;
    }

    if (currentMinutes >= openMinutes && currentMinutes < closeMinutes) {
      return "Open";
    }

    if (currentMinutes < openMinutes) {
      final diff = openMinutes - currentMinutes;
      if (diff <= 240) {
        final h = diff ~/ 60;
        final m = diff % 60;
        return h >= 1 ? "Opens in ${h}h" : "Opens in ${m}m";
      }
    }

    return "Closed";
  }
}
