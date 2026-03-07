import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:munch_nearby/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:munch_nearby/features/restaurant/presentation/state/restaurant_state.dart';
import 'package:munch_nearby/features/restaurant/presentation/view_model/restaurant_view_model.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String? initialRestaurantId;

  const MapScreen({super.key, this.initialRestaurantId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  AnimationController? _mapMoveController;
  bool _isMapReady = false;
  bool _movedToRestaurant = false;
  bool _initialRestaurantSelected = false;

  // User location
  LatLng? _userLocation;
  bool _locationLoading = true;

  // Search
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;

  // Selected restaurant & routing
  RestaurantEntity? _selectedRestaurant;
  List<LatLng> _routePoints = [];
  bool _routeLoading = false;
  String? _routeDistance;
  String? _routeDuration;

  // Pulse animation for user marker
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const LatLng _defaultCenter = LatLng(27.7172, 85.3240);
  static const Color _primaryColor = Color(0xFFE87A5D);
  static const Color _primaryLight = Color(0xFFF6B88F);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.4,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    Future.microtask(() {
      ref.read(restaurantViewModelProvider.notifier).getRestaurants();
    });

    _getUserLocation();
  }

  @override
  void dispose() {
    _mapMoveController?.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() => _locationLoading = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _locationLoading = false;
        });
        _tryAutoSelectRestaurant();
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  void _tryAutoSelectRestaurant() {
    if (_initialRestaurantSelected || widget.initialRestaurantId == null)
      return;
    if (_userLocation == null) return;

    final restaurants = _validRestaurants;
    if (restaurants.isEmpty) return;

    final match = restaurants.where((r) => r.id == widget.initialRestaurantId);
    if (match.isEmpty) return;

    _initialRestaurantSelected = true;
    _selectRestaurant(match.first);
  }

  // Filter restaurants with valid coordinates
  List<RestaurantEntity> get _validRestaurants {
    final state = ref.read(restaurantViewModelProvider);
    return state.restaurants
        .where((r) => r.latitude != null && r.longitude != null)
        .toList();
  }

  // Search suggestions
  List<RestaurantEntity> get _suggestions {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return [];
    return _validRestaurants
        .where((r) => r.name.toLowerCase().contains(query))
        .take(8)
        .toList();
  }

  void _selectRestaurant(RestaurantEntity restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
      _searchController.text = restaurant.name;
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();

    final target = LatLng(restaurant.latitude!, restaurant.longitude!);
    _animatedMapMove(target, 16);

    if (_userLocation != null) {
      _fetchRoute(_userLocation!, target);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedRestaurant = null;
      _routePoints = [];
      _routeDistance = null;
      _routeDuration = null;
      _searchController.clear();
      _showSuggestions = false;
    });
  }

  void _animatedMapMove(LatLng target, double zoom) {
    if (!_isMapReady || !mounted) return;

    _mapMoveController?.stop();
    _mapMoveController?.dispose();

    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: zoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _mapMoveController = controller;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    controller.addListener(() {
      if (!mounted || !_isMapReady) return;
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (_mapMoveController == controller) {
          _mapMoveController = null;
        }
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    setState(() => _routeLoading = true);

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};'
        '${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry']['coordinates'] as List;
          final distance = routes[0]['distance'] as num;
          final duration = routes[0]['duration'] as num;

          final points = geometry
              .map<LatLng>(
                (coord) => LatLng(
                  (coord[1] as num).toDouble(),
                  (coord[0] as num).toDouble(),
                ),
              )
              .toList();

          if (mounted) {
            setState(() {
              _routePoints = points;
              _routeDistance = distance >= 1000
                  ? '${(distance / 1000).toStringAsFixed(1)} km'
                  : '${distance.toInt()} m';
              _routeDuration = duration >= 3600
                  ? '${(duration / 3600).toStringAsFixed(1)} hr'
                  : '${(duration / 60).toStringAsFixed(0)} min';
            });
          }

          // Fit map to show both points
          _fitBounds(from, to);
        }
      }
    } catch (e) {
      debugPrint('Route error: $e');
    } finally {
      if (mounted) setState(() => _routeLoading = false);
    }
  }

  void _fitBounds(LatLng a, LatLng b) {
    if (!_isMapReady) return;
    final bounds = LatLngBounds(a, b);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantState = ref.watch(restaurantViewModelProvider);

    final registeredRestaurants = restaurantState.restaurants
        .where((r) => r.latitude != null && r.longitude != null)
        .toList();

    if (_isMapReady &&
        !_movedToRestaurant &&
        registeredRestaurants.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_isMapReady || _movedToRestaurant) return;
        _mapController.move(
          LatLng(
            registeredRestaurants.first.latitude!,
            registeredRestaurants.first.longitude!,
          ),
          13,
        );
        _movedToRestaurant = true;
        _tryAutoSelectRestaurant();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: registeredRestaurants.isNotEmpty
                  ? LatLng(
                      registeredRestaurants.first.latitude!,
                      registeredRestaurants.first.longitude!,
                    )
                  : _defaultCenter,
              initialZoom: 13,
              onMapReady: () => _isMapReady = true,
              onTap: (_, __) {
                setState(() => _showSuggestions = false);
                _searchFocusNode.unfocus();
              },
            ),
            children: [
              // Map tiles
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.munch.nearby',
              ),

              // Route polyline
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: _primaryColor.withValues(alpha: 0.8),
                    ),
                  ],
                ),

              // Restaurant markers
              MarkerLayer(
                markers: registeredRestaurants.map((restaurant) {
                  final isSelected = _selectedRestaurant?.id == restaurant.id;
                  return Marker(
                    point: LatLng(restaurant.latitude!, restaurant.longitude!),
                    width: 140,
                    height: 70,
                    child: GestureDetector(
                      onTap: () => _selectRestaurant(restaurant),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Restaurant icon
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_primaryColor, _primaryLight],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white,
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                                if (isSelected)
                                  BoxShadow(
                                    color: _primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Restaurant name label
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.08),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              restaurant.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? _primaryColor
                                    : const Color(0xFF111827),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // User location marker
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 50,
                      height: 50,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulse ring
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primaryColor.withValues(
                                    alpha: _pulseAnimation.value,
                                  ),
                                ),
                              ),
                              // Inner dot
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primaryColor,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryColor.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

              // Loading indicator
              if (restaurantState.status == RestaurantStatus.loading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),

          // Floating header panel
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (_) {
                            setState(() => _showSuggestions = true);
                          },
                          onTap: () {
                            setState(() => _showSuggestions = true);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search restaurant name...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: _clearSelection,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Search suggestions dropdown
                if (_showSuggestions && _suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                      itemBuilder: (context, index) {
                        final r = _suggestions[index];
                        return InkWell(
                          onTap: () => _selectRestaurant(r),
                          borderRadius: BorderRadius.vertical(
                            top: index == 0
                                ? const Radius.circular(14)
                                : Radius.zero,
                            bottom: index == _suggestions.length - 1
                                ? const Radius.circular(14)
                                : Radius.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                if (r.address.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    r.address,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // No matches message
                if (_showSuggestions &&
                    _searchController.text.trim().isNotEmpty &&
                    _suggestions.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'No matches found.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Route info & clear route panel (bottom)
          if (_selectedRestaurant != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primaryColor.withValues(alpha: 0.1),
                      _primaryLight.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _primaryColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryColor, _primaryLight],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedRestaurant!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              if (_selectedRestaurant!.address.isNotEmpty)
                                Text(
                                  _selectedRestaurant!.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_routeLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    if (_routeDistance != null && _routeDuration != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.navigation,
                            size: 16,
                            color: _primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_routeDistance  ·  $_routeDuration',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _clearSelection,
                        style: TextButton.styleFrom(
                          foregroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'CLEAR ROUTE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Location button (bottom right)
          if (_userLocation != null && _selectedRestaurant == null)
            Positioned(
              bottom: 24,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () => _animatedMapMove(_userLocation!, 16),
                backgroundColor: Colors.white,
                foregroundColor: _primaryColor,
                elevation: 4,
                child: const Icon(Icons.my_location),
              ),
            ),

          // Location loading indicator
          if (_locationLoading)
            Positioned(
              bottom: 24,
              right: 16,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
