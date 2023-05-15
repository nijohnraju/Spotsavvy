import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panigale/custom.dart';
import 'package:panigale/screens/bookparking/book_parking.dart';
import 'package:panigale/screens/profile.dart';
import 'package:panigale/screens/rentparking/rent_parking.dart';
import 'package:panigale/screens/search.dart';
import 'package:panigale/screens/settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  final screens = [
    const HomePage(),
    const SearchPage(),
    const ProfilePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: blacksavvy,
        selectedItemColor: greensavvy,
        unselectedItemColor: whitesavvy,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            //backgroundColor: blacksavvy,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
            //backgroundColor: whitesavvy,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            //backgroundColor: whitesavvy,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            //backgroundColor: whitesavvy,
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentAddress = '';
  String? _name;

  @override
  void initState() {
    super.initState();
    _getCurrentUserName();
    _getCurrentLocation();
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
      currentAddress = "${place.locality}";
    });
  }

  Future<void> _getCurrentUserName() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    String name = userSnapshot.get('Name');

    setState(() {
      _name = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitesavvy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Hi, ',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$_name!',
                            style: TextStyle(
                              fontSize: 22,
                              color: blacksavvy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      //location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: blacksavvy,
                          ),
                          const SizedBox(
                            width: 3,
                          ),

                          // Update with live location

                           Text(
                            currentAddress,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: blacksavvy,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Text(
                        'Find Your',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Parking Spot',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(08),
                    child: Container(
                      decoration: customDecoration(),
                      padding: const EdgeInsets.all(12),
                      // width: 165,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: greensavvy,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Search Your Parking Spot',
                            style: TextStyle(
                              color: blacksavvy,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BookPage()),
                          );
                        },
                        borderRadius: BorderRadius.circular(08),
                        child: Container(
                          decoration: BoxDecoration(
                            color: blacksavvy,
                            borderRadius: BorderRadius.circular(08),
                          ),
                          padding: const EdgeInsets.all(12),
                          // width: 165,
                          alignment: Alignment.center,
                          child: Text(
                            'Booked Parkings',
                            style: TextStyle(
                              color: whitesavvy,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RentPage()),
                          );
                        },
                        borderRadius: BorderRadius.circular(08),
                        child: Container(
                          decoration: BoxDecoration(
                            //imp color
                            color: greensavvy,
                            borderRadius: BorderRadius.circular(08),
                          ),
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.center,
                          //width: 165,
                          child: Text(
                            'Listed Parkings',
                            style: TextStyle(
                              color: blacksavvy,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: blacksavvy,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0))),
                alignment: Alignment.center,
                child: const Text(
                  'Space for adding Recent tabs or may be a guide',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
