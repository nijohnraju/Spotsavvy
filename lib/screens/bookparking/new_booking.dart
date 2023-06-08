import 'package:flutter/material.dart';
import 'package:panigale/custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panigale/screens/bookparking/book_parking.dart';

class NewBooking extends StatefulWidget {
  final double bookingFee;
  final String spotName;
  const NewBooking(
      {super.key, required this.bookingFee, required this.spotName});

  @override
  State<NewBooking> createState() => _NewBookingState();
}

class _NewBookingState extends State<NewBooking> {
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  double _sliderValue = 3;

  void uploadData({
    required String title,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
      .collection('Rentdetails')
      .where('Title', isEqualTo: title)
      .get();
  if(querySnapshot.docs.length == 1){
    DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
    Map<String, dynamic> newData = {
    'Book': true,
    'Book_uid': uid,
  };
  await documentSnapshot.reference.update(newData);
      
  }
  }

  @override
  Widget build(BuildContext context) {
    double bookingAmount = widget.bookingFee;
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? newDate = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: date,
                        lastDate: date.add(
                          const Duration(days: 2),
                        ),
                      );
                      if (newDate == null) return;

                      setState(() {
                        date = newDate;
                      });
                    },
                    child: const Text(
                      'Select Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '$hours:$minutes',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: time,
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (newTime == null) return;

                      setState(() {
                        time = newTime;
                      });
                    },
                    child: const Text(
                      'Select Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            "Choose Parking Time (in Hours)",
            style: TextStyle(fontWeight: FontWeight.bold, color: blacksavvy),
          ),
          const SizedBox(
            height: 10,
          ),
          Slider(
            value: _sliderValue,
            min: 1,
            max: 6,
            divisions: 5,
            label: _sliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Amount to Be Paid",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          Text(
            '₹ ${(bookingAmount * _sliderValue).toString()}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                  onPressed: (){
                    uploadData(title: widget.spotName);
                    Navigator.pop(context);
                   Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BookPage()),
                      );
                  },
                  child: const Text(
                    'Book Your Spot',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ]),
      ),
    );
  }
}
