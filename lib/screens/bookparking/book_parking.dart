import 'package:flutter/material.dart';
import 'package:panigale/custom.dart';

import 'package:panigale/screens/bookparking/fetch_booking.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  // void _openAddExpenseOverlay() {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (ctx) => SizedBox(
  //       height: MediaQuery.of(context).size.height,
  //       child: const NewParking(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitesavvy,
      appBar: AppBar(
        backgroundColor: whitesavvy,
        title: Text(
          'Your Booked Parkings',
          style: TextStyle(
            color: blacksavvy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'No Parking Spots Booked',
          style: TextStyle(
            color: greensavvy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ParkingItemAll()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
