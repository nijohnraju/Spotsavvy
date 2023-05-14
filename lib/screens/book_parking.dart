import 'package:flutter/material.dart';
import 'package:panigale/custom.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: greensavvy),
      body: const Center(
        child: Text(
          'Book A Parking Spot',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
