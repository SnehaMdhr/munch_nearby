import 'package:flutter/material.dart';
import 'package:munch_nearby/widgets/top_search_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SafeArea(child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopSearchBar()
            ]
        ),
      ))
    );
  }
}
