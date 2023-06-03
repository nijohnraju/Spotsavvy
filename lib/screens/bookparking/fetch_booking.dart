import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panigale/custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panigale/screens/bookparking/new_booking.dart';

class ParkingItemAll extends StatefulWidget {
  const ParkingItemAll({super.key});

  @override
  State<ParkingItemAll> createState() => _ParkingItemAllState();
}

class _ParkingItemAllState extends State<ParkingItemAll> {
  late String _uid;
  double? currentAmount;
  String? spotName;
  _openAddBookingssOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: NewBooking(
          bookingFee: currentAmount!,
          spotName: spotName!,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUserUID();
  }

  Future<void> _getCurrentUserUID() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whitesavvy,
        title: Text(
          'Available Parkings',
          style: TextStyle(
            color: greensavvy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Rentdetails')
            .where('uid', isNotEqualTo: _uid)
            .where('Book', isEqualTo: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Parkings Found.',
                style: TextStyle(
                  color: greensavvy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = snapshot.data!.docs[index];
              final title = doc.get('Title') ?? '';
              final amount = doc.get('Amount') ?? 0.0;
              final image = doc.get('Image') ?? '';
              final location = doc.get('Location') ?? {};
              //final latitude = location['latitude'] ?? 0.0;
              // final longitude = location['longitude'] ?? 0.0;
              final address = location['address'] ?? '';

              return Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 2),
                child: Card(
                  color: Colors.white,
                  shadowColor: greensavvy,
                  shape: null,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: blacksavvy,
                          height: 230,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: image != null
                              ? Image.network(
                                  image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : const CircularProgressIndicator(),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Amount   :   ₹$amount /hr',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Location :   $address ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    currentAmount = amount;
                                    spotName =
                                        title; // Update the currentAmount variable
                                  });
                                  _openAddBookingssOverlay();
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation:
                                        4, // Set the elevation for the shadow effect
                                    shadowColor: Colors.black,
                                    backgroundColor: const Color.fromARGB(
                                        255,
                                        198,
                                        236,
                                        187) // Set the color of the shadow
                                    ),
                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
