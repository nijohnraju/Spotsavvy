import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panigale/custom.dart';

class ParkingItem extends StatefulWidget {
  const ParkingItem({super.key});

  @override
  State<ParkingItem> createState() => _ParkingItemState();
}

class _ParkingItemState extends State<ParkingItem> {
  late String _uid;

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Rentdetails')
            .where('uid', isEqualTo: _uid)
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
              child: Text('No Parkings Spots Found.',style: TextStyle(color:greensavvy,fontWeight: FontWeight.bold,),),
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
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
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
                        ]),
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
