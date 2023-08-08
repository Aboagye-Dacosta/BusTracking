import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class UserLocationProvider extends ChangeNotifier {
  late loc.Location _location;
  loc.Location get location => _location;
  late LatLng _locationPosition;
  LatLng get locationPosition => _locationPosition;
  StreamSubscription<loc.LocationData>? _locationSubscription;

  bool locationServicesActive = true;

  UserLocationProvider() {
    _location = loc.Location();
  }
  initialize() async {
    getLocation();
  }

  getLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();

    // ignore: unrelated_type_equality_checks
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();

      // ignore: unrelated_type_equality_checks
      if (permissionGranted == PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = location.onLocationChanged
        .handleError((error) {})
        .listen((loc.LocationData currentLocation) {
      _locationPosition =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);

      notifyListeners();
    });
  }

  terminate() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
  }
}
