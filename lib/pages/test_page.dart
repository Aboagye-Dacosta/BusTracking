// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;

// class MyMap extends StatefulWidget {
//   const MyMap({super.key});


//   @override
//   _MyMapState createState() => _MyMapState();
// }

// class _MyMapState extends State<MyMap> {
//   LatLng? currentPosition;
//   final Completer<GoogleMapController> _handler = Completer();
//   Set<Marker> markers = {};

//   @override
//   void initState() {
//     getcurrentlocation();
//     super.initState();
//   }

//   void getcurrentlocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       currentPosition = LatLng(position.latitude, position.longitude);
//       markers.add(Marker(
//           markerId: MarkerId('12'),
//           position: currentPosition!,
//           infoWindow: InfoWindow(title: 'Hi domber')));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       child: currentPosition != null
//           ? GoogleMap(
//               mapType: MapType.normal,
//               markers: markers,
//               initialCameraPosition:
//                   CameraPosition(target: currentPosition!, zoom: 15),
//               onMapCreated: (GoogleMapController controller) {
//                 _handler.complete(controller);
//               },
//             )
//           : SizedBox(),
//     );
//   }
// }
