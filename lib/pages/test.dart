import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationTrackingScreen extends StatefulWidget {
  @override
  _LocationTrackingScreenState createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  LocationData? _currentLocation;
  Location _location = Location();
  late StreamSubscription<LocationData> _locationSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  void _startLocationTracking() {
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentLocation = locationData;
      });
    });
  }

  void _stopLocationTracking() {
    _locationSubscription.cancel();
  }

  @override
  void dispose() {
    _stopLocationTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location Tracking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentLocation != null)
              Text(
                'Latitude: ${_currentLocation!.latitude}\nLongitude: ${_currentLocation!.longitude}',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
             SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopLocationTracking,
              child: Text('Stop Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
