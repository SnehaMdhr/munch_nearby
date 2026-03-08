import 'package:flutter/material.dart';
import 'package:munch_nearby/features/menu/domain/entities/menu_entity.dart';
import 'package:munch_nearby/features/menu/presentation/state/menu_state.dart';

class MenuSection extends StatelessWidget {
  final MenuState state;
  final Widget Function(MenuEntity) menuItemBuilder;

  const MenuSection({
    super.key,
    required this.state,
    required this.menuItemBuilder,
  });

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
    if (state.status == MenuStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.menus.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text("No items available."),
        ),
      );
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2A44),
              ),
            ),
            const SizedBox(height: 15),
            ...entry.value.map((menu) => menuItemBuilder(menu)),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }
}
