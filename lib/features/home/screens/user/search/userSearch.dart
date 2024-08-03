import 'package:flutter/material.dart';  // Import material package for Flutter
import '../../../../../common/widgets/appbar/appbar.dart';  // Import your custom AppBar

class UserSearch extends StatelessWidget {
  const UserSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        // You can add actions or other parameters to TAppBar if needed
        title: const Text('Search'),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Handle search logic here
              },
            ),
            // Add additional widgets or logic here for search results or functionality
          ],
        ),
      ),
    );
  }
}

