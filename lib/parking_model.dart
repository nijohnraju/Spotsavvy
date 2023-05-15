import 'dart:io';

class PlaceLocation{
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address, 
  });
  final double latitude;
  final double longitude;
  final String address;
}

class RentParkingModel {
  RentParkingModel(
      {
      required this.title,
      required this.amount,
      required this.image,
      required this.location,
      });
  final String title;
  final double amount;
  final File image;
  final PlaceLocation location;

}