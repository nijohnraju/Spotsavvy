import 'package:flutter/material.dart';
import 'package:panigale/custom.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: greensavvy),
      body: const Center(
        child: Text(
          'Search Your Parking Spot',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
