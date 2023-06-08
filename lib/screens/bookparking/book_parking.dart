import 'package:flutter/material.dart';
import 'package:panigale/custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panigale/screens/bookparking/fetch_booking.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late String _uid;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUID();
  }

  Future<void> updateBookingStatus(String docId) async {
  await FirebaseFirestore.instance
      .collection('Rentdetails')
      .doc(docId)
      .update({'Book': false});
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
      backgroundColor: whitesavvy,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ParkingItemAll()),
                );
              },
              icon: const Icon(Icons.add),color: greensavvy,)
        ],
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Rentdetails')
            .where('Book_uid', isEqualTo: _uid)
            .where('Book',isEqualTo: true)
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
            return  Center(
              child: Text('No Bookings Found.',style: TextStyle(color:greensavvy,fontWeight: FontWeight.bold,),),
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
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: Card(
                  color: Colors.white,
                  shadowColor: greensavvy,
                  shape: null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: blacksavvy,
                            height: 200,
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
                          const SizedBox(height: 5,),
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
                              child: TextButton(
                                onPressed:
                                  (){
                                    updateBookingStatus(doc.id);
                                  }
                                ,
                                // style: TextButton.styleFrom(
                                //     elevation:
                                //         4, // Set the elevation for the shadow effect
                                //     shadowColor: Colors.black,
                                //     backgroundColor: Color.fromRGBO(255, 255, 255, 1) // Set the color of the shadow
                                //     ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Color.fromARGB(171, 232, 27, 27),
                                      fontWeight: FontWeight.bold,),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ]),
                  ),
                ),
              );
            },
          );
        },
      ),
      // Center(
      //   child: Text(
      //     'No Parking Spots Booked',
      //     style: TextStyle(
      //       color: greensavvy,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const ParkingItemAll()),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
