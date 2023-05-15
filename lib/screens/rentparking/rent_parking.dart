import 'package:flutter/material.dart';
import 'package:panigale/custom.dart';

import 'package:panigale/screens/rentparking/fetch_parking.dart';
import 'package:panigale/screens/rentparking/new_parking.dart';

class RentPage extends StatefulWidget {
  const RentPage({super.key});

  @override
  State<RentPage> createState() => _RentPageState();
}

class _RentPageState extends State<RentPage> {
  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height,
        child: const NewParking(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitesavvy,
      appBar: AppBar(
        backgroundColor: whitesavvy,
        title: Text(
          'Your Listed Parkings',
          style: TextStyle(
            color: blacksavvy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: const ParkingItem(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseOverlay,
        child: const Icon(Icons.add),
      ),
    );
  }
}
