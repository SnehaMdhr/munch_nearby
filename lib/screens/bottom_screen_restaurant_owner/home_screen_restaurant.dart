import 'package:flutter/material.dart';
import 'package:munch_nearby/widgets/dashboard_card.dart';

class HomeScreenRestaurant extends StatelessWidget {
  const HomeScreenRestaurant({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 24),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: const [
                  DashboardCard(
                    icon: Icons.star_border,
                    title: "Total Reviews",
                    value: "1,204",
                  ),
                  DashboardCard(
                    icon: Icons.star_rate_rounded,
                    title: "Average Rating",
                    value: "4.7",
                  ),
                  DashboardCard(
                    icon: Icons.menu_book_outlined,
                    title: "Menu Items",
                    value: "58",
                  ),
                  DashboardCard(
                    icon: Icons.remove_red_eye_outlined,
                    title: "Recent Views",
                    value: "350",
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// Manage Menu Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.menu_open),
                  label: const Text(
                    "Manage Menu",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// View Reviews Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text(
                    "View Reviews",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEB7A5C),
                    backgroundColor: const Color(0xFFFBE7E0),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
