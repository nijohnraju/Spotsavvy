import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GoogleMapController? googleMapController;
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.15478, -122.78945), zoom: 14.0);
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  TextEditingController searchController = TextEditingController();
  LatLng? searchedLocation;

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    try {
      Position position = await _getCurrentLocation();
      setState(() {
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () {
              setState(() {});
              fetchDirections(position.latitude, position.longitude,
                  markers.elementAt(1).position.latitude, markers.elementAt(1).position.longitude);
            },
          ),
        );
      });

      FirebaseFirestore.instance.collection('Rentdetails').get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var location = doc.get('Location');
          var latitude = location['latitude'];
          var longitude = location['longitude'];

          setState(() {
            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(latitude, longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                onTap: () {
                  setState(() {});
                  fetchDirections(position.latitude, position.longitude, latitude, longitude);
                },
              ),
            );
          });
        });
      });
    } catch (e) {
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

  Future<void> fetchDirections(
      double originLat, double originLng, double destinationLat, double destinationLng) async {
    String apiKey = 'AIzaSyDC6Itbcw16HH1H7-eQymYXU7ejd1WPQeI';
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&key=$apiKey';

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          polylines.clear();

          List<LatLng> polylineCoordinates = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
          Polyline polyline = Polyline(
            polylineId: const PolylineId('directions'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          );
          polylines.add(polyline);
        });
      } else {
        print('Error fetching directions: ${data['error_message']}');
      }
    } else {
      print('Error fetching directions. Status code: ${response.statusCode}');
    }
  }

  List<LatLng> _decodePolyline(String encodedPolyline) {
    List<LatLng> polylinePoints = [];
    int index = 0, len = encodedPolyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encodedPolyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encodedPolyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      LatLng point = LatLng(latitude, longitude);
      polylinePoints.add(point);
    }

    return polylinePoints;
  }

  Future<void> searchPlace() async {
    String query = searchController.text;
    List<Location> locations = await locationFromAddress(query);

    if (locations.isNotEmpty) {
      Location location = locations.first;
      setState(() {
        searchedLocation = LatLng(location.latitude, location.longitude);
        markers.add(
          Marker(
            markerId: const MarkerId('searchedLocation'),
            position: searchedLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () {
              setState(() {});
              fetchDirections(
                markers.elementAt(0).position.latitude,
                markers.elementAt(0).position.longitude,
                searchedLocation!.latitude,
                searchedLocation!.longitude,
              );
            },
          ),
        );
        googleMapController!.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              searchedLocation!.latitude - 0.05,
              searchedLocation!.longitude - 0.05,
            ),
            northeast: LatLng(
              searchedLocation!.latitude + 0.05,
              searchedLocation!.longitude + 0.05,
            ),
          ),
          0,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Book A Parking Spot',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            polylines: polylines,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search for a place',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: searchPlace,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _getCurrentLocation();
          googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ));
        },
        label: const Text("Current Location"),
      ),
    );
  }
}
