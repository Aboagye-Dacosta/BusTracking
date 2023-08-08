import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  final String? busId;
  final String driverId;
  final String? busNumber;
  final Location location;
  final String currentDestination;
  final String startPoint;
  final BusState busState;
  final String driverState;
  final List<dynamic>? destinations;
  final List<dynamic>? startPoints;

  BusModel(
      {required this.driverState,
      required this.currentDestination,
      required this.startPoint,
      this.busId,
      this.destinations,
      this.startPoints,
      required this.driverId,
      this.busNumber,
      required this.location,
      required this.busState});

  toJson() {
    return {
      "driverId": driverId,
      "driverState": driverState,
      "busState": busState == BusState.full ? "full" : "not full",
      "currentDestination": currentDestination,
      "startPoint": startPoint,
      "location": {"lat": location.lat, "lng": location.long}
    };
  }

  factory BusModel.fromSnapShot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return BusModel(
        busId: doc.id,
        busNumber: data["bussNumber"],
        driverId: data["driverId"],
        busState: data["busState"] == "full" ? BusState.full : BusState.notFull,
        location: Location(
            lat: data["location"]["lat"], long: data["location"]["lng"]),
        currentDestination: data["currentDestination"],
        startPoint: data["startPoint"],
        driverState: data["driverState"]);
  }
}

enum BusState { full, notFull }

class Location {
  final double lat;
  final double long;

  Location({required this.lat, required this.long});
}
