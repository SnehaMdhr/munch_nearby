import 'package:flutter/material.dart';
import 'package:munch_nearby/features/customer_dashboard/presentation/widgets/profile_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: const Color(0xFFFFF6F1),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFFFD6C9),
                  child: const CircleAvatar(
                    radius: 44,
                    backgroundImage: AssetImage(
                      "assets/images/avatar.png", // optional
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Alex Doe",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "alex.doe@email.com",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 30),

                // Menu List
                ProfileItem(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {},
                ),
                ProfileItem(
                  icon: Icons.star_border,
                  title: "My Reviews",
                  onTap: () {},
                ),
                ProfileItem(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {},
                ),

                const Spacer(),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text("Logout"),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
