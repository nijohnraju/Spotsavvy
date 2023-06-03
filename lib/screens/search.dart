import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:panigale/custom.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState;
    fetchLocation();
  }

  String location = 'reading';
  String address = 'Enabling Location...';

  late GoogleMapController googleMapController;
//final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.15478, -122.78945), zoom: 14.0);
  Set<Marker> markers = {};

  Future<Position> fetchLocation() async {
    try {
      Position position = await _getCurrentLocation();
      location = 'Lat: ${position.latitude}, Long: ${position.longitude}';
      //await GetAddressFromLatLong(position);
      setState(() {});
      return position;
    } catch (e) {
      setState(() {
        location = 'Error getting location';
      });
      throw Exception('Error getting location');
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location Permissions are denied';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    return await Geolocator.getCurrentPosition();
  }

/*  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark);
    Placemark place = placemark[0];
    address = '${place.locality}, ${place.country}';
  }*/

//static const CameraPosition targetPosition = CameraPosition(target: LatLng(33.15478, -135.78945), zoom: 14.0, bearing: 192.0,tilt: 60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: whitesavvy,
          title: const Text(
            'Book A Parking Spot',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await fetchLocation();
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 14)));
          markers.clear();
          markers.add(Marker(
              markerId: const MarkerId('currentLoction'),
              position: LatLng(position.latitude, position.longitude)));
          setState(() {});
        },
        label: const Text("current location"),
        icon: const Icon(Icons.location_history),
      ),
    );
  }
}
