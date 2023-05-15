import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panigale/custom.dart';

import 'dart:io';
import 'package:uuid/uuid.dart';

import 'package:panigale/parking_model.dart';

class NewParking extends StatefulWidget {
  const NewParking({
    super.key,
  });

  @override
  State<NewParking> createState() => _NewParkingState();
}

class _NewParkingState extends State<NewParking> {
  bool chargingAvailable = false;
  bool carWashAvailable = false;


  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  

  File? _selectedImage;
  PlaceLocation? _pickedLocation;
  final uuid = const Uuid();

  String currentAddress = '________';
  Position? currentPosition;

  Future uploadData({
    required String title,
    required double amount,
    required File image,
    required PlaceLocation location,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    final id = uuid.v4();
    final snapshot = await FirebaseStorage.instance
        .ref()
        .child('images')
        .child(uid)
        .child(id)
        .putFile(image);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('Rentdetails').doc(id).set({
      'Id': id,
      'Title': title,
      'Amount': amount,
      'Image': downloadUrl,
      'uid': uid,
      'Location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': location.address,
      },
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location Services are disabled");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permission are permanently denied");
    }
    setState(() {
      currentAddress = "updating...";
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];

    setState(() {
      currentPosition = position;
      currentAddress = "${place.locality}, ${place.postalCode}";
      _pickedLocation = PlaceLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: currentAddress);
    });
  }

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  void _choosefromGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }


  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvaled = enteredAmount == null || enteredAmount <= 0;
    if (_nameController.text.trim().isEmpty ||
        amountIsInvaled ) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invaled input'),
          content: const Text(
              "Please make sure a valid title and  amount was entered"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
      return;
    }

    uploadData(
        title: _nameController.text,
        amount: enteredAmount,
        image: _selectedImage!,
        location: _pickedLocation!);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera),
          label: const Text(
            'Camera',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _choosefromGallery,
          icon: const Icon(Icons.image),
          label: const Text(
            'Gallery',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _choosefromGallery,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: blacksavvy,
                      fontWeight: FontWeight.bold,
                    ),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      label: Text(
                        'Name ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: blacksavvy,
                      fontWeight: FontWeight.bold,
                    ),
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: "₹",
                      label: Text(
                        'Amount / hr',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: blacksavvy.withOpacity(0.35),
                ),
              ),
              height: 230,
              width: double.infinity,
              alignment: Alignment.center,
              child: content,
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Text(
                  'Your location : $currentAddress',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text(
                    'Locate me',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                      title: const Text(
                        "EV Charging Dock",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: chargingAvailable,
                      onChanged: (bool? value) {
                        setState(() {
                          chargingAvailable = value!;
                        });
                      }),
                ),
                Expanded(
                  child: CheckboxListTile(
                      title:const  Text(
                        "Car Wash",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      //secondary: Icon(Icons.electric_bolt),
                      value: carWashAvailable,
                      onChanged: (bool? value) {
                        setState(() {
                          carWashAvailable = value!;
                        });
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                ElevatedButton(
                    onPressed: _submitExpenseData,
                    child: const Text('Save Parking',style: TextStyle(fontWeight: FontWeight.bold),)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
