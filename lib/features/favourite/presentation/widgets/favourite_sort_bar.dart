import 'package:flutter/material.dart';

class FavouriteSortBar extends StatelessWidget {
  final String sortBy;
  final Function(String) onChanged;

  const FavouriteSortBar({
    super.key,
    required this.sortBy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: sortBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: const [
                DropdownMenuItem(value: "name", child: Text("Sort: A-Z")),
                DropdownMenuItem(
                  value: "rating",
                  child: Text("Sort: Top Rated"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
