// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as loc;

// class MapComponent extends StatefulWidget {
//   final String userId;
//   const MapComponent({super.key, required this.userId});

//   @override
//   State<MapComponent> createState() => _MapComponentState();
// }

// class _MapComponentState extends State<MapComponent> {

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
        
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        

//           print("-----------------" +
//               snapshot.data!.docs
//                   .where((el) {
//                     print(el.data());
//                     final data = el.data() as Map<String, dynamic>;
//                     return data["driverId"] == widget.userId;
//                   })
//                   .first["driverId"]
//                   .toString());
//           return 
//         });
//   }


// }
