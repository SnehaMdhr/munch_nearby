import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/features/menu/presentation/view_model/menu_view_model.dart';

import '../state/menu_state.dart';
import '../../domain/entities/menu_entity.dart';

class MenuScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const MenuScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(menuViewModelProvider.notifier)
          .fetchMenus(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
        centerTitle: true,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(MenuState state) {
    if (state.status == MenuStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == MenuStatus.error) {
      return Center(
        child: Text(
          state.errorMessage ?? "Something went wrong",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.status == MenuStatus.loaded) {
      if (state.menus.isEmpty) {
        return const Center(child: Text("No menu available"));
      }

      final groupedMenus = _groupByCategory(state.menus);

      return ListView(
        padding: const EdgeInsets.all(16),
        children: groupedMenus.entries.map((entry) {
          final category = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryHeader(category),
              const SizedBox(height: 10),
              ...items.map(_buildMenuItemCard).toList(),
              const SizedBox(height: 25),
            ],
          );
        }).toList(),
      );
    }

    return const SizedBox();
  }

  // 🔥 Group by Category
  Map<String, List<MenuEntity>> _groupByCategory(
      List<MenuEntity> menus) {
    final Map<String, List<MenuEntity>> map = {};

    for (var menu in menus) {
      if (!map.containsKey(menu.category)) {
        map[menu.category] = [];
      }
      map[menu.category]!.add(menu);
    }

    return map;
  }

  // 🎯 Category Header
  Widget _buildCategoryHeader(String category) {
    return Text(
      category,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // 🍔 Menu Item Card
  Widget _buildMenuItemCard(MenuEntity menu) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          menu.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(menu.description ??""),
        trailing: Text(
          "Rs. ${menu.price.toStringAsFixed(2)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}