import 'package:flutter/material.dart';
import 'package:munch_nearby/widgets/top_search_bar.dart';

import '../../widgets/restaurant_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SafeArea(child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopSearchBar(),
              const SizedBox(height: 20),

              const RestaurantCard(
                image: "assets/images/chiya.png",
                name: "Chiya Aada",
                rating: 4.9,
                type: "Cafe",
                distance: "0.3 mi",
              ),
              const SizedBox(height: 20),

              const RestaurantCard(
                image: "assets/images/chiya.png",
                name: "Bella Luna",
                rating: 4.8,
                type: "Italian",
                distance: "0.5 mi",
              ),
              const SizedBox(height: 20),

              const RestaurantCard(
                image: "assets/images/chiya.png",
                name: "Green Leaf",
                rating: 4.7,
                type: "Vegan",
                distance: "0.6 mi",
              ),
            ]
        ),
      ))
    );
  }
}
