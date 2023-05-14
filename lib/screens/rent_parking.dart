import 'package:flutter/material.dart';
import 'package:panigale/custom.dart';

class RentPage extends StatelessWidget {
  const RentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: greensavvy),
      body: const Center(
        child: Text(
          'Rent Your Parking Spot',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
