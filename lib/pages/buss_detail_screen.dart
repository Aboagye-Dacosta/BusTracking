import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/components/spacing_component.dart';
import 'package:project/model/bus.dart';
import 'package:project/presentation/colors.dart';
import 'package:project/presentation/sizing.dart';
import 'package:project/presentation/strings.dart';
import 'package:location/location.dart' as loc;
import 'package:project/provider/location_provider.dart';
import 'package:provider/provider.dart';

//car id
//driver id
//to
//from
//state

class BussDetail extends StatefulWidget {
  const BussDetail({super.key});

  static const String routeName = "/bussDetail";

  @override
  State<BussDetail> createState() => _BussDetailState();
}

class _BussDetailState extends State<BussDetail> {
  late loc.Location location = loc.Location();
  late BitmapDescriptor _markerbitmapBus;
  late BitmapDescriptor _markerbitmapStudent;

  late GoogleMapController _mapController;
  bool _add = false;
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = FlutterConfig.get("GOOGLE_MAP_API_KEY");
  Map<PolylineId, Polyline> polylines = {};
  double _distance = -1;
  String _time = "-1";

  @override
  void initState() {
    super.initState();
    Provider.of<UserLocationProvider>(context, listen: false).initialize();
    _myCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      _add = true;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _myCurrentLocation() async {
    _markerbitmapBus = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(AppSizing.h_54, AppSizing.h_54)),
      "assets/images/bus.png",
    );
    _markerbitmapStudent = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(AppSizing.h_8, AppSizing.h_8)),
      "assets/images/man.png",
    );
  }

  _getDirections(LatLng startLocation, LatLng endLocation) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {}
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;

    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }

    String formatTime(double seconds) {
      if (seconds < 60) {
        return '${seconds.toStringAsFixed(2)} seconds';
      } else if (seconds < 3600) {
        double minutes = seconds / 60;
        return '${minutes.toStringAsFixed(2)} minutes';
      } else {
        double hours = seconds / 3600;
        return '${hours.toStringAsFixed(2)} hours';
      }
    }

    String time;

    if (totalDistance == 0) {
      time = "0";
    } else {
      time = formatTime(totalDistance / 10);
    }

    setState(() {
      _time = time;
      _distance = totalDistance;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    BusModel model = map["bussData"]!;
    String studentName = map["studentName"];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppStrings.splashScreenMainText,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppFontSizes.fs_16,
              color: AppColors.dark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("Bus").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            BusModel busModel = snapshot.data!.docs
                .where((e) => e.data()["driverId"] == model.driverId)
                .map((e) {
                  final data = e.data();
                  return _genBusModel(e, data);
                })
                .toList()
                .first;

            final LatLng latLng =
                LatLng(busModel.location.lat, busModel.location.long);

            if (_add) {
              mymap(busModel);
            }

            return Stack(
              children: [
                Consumer<UserLocationProvider>(
                    builder: (context, value, child) {
                  // ignore: unnecessary_null_comparison
                  if (value.locationPosition != null) {
                    _getDirections(value.locationPosition, latLng);
                  }

                  // ignore: unnecessary_null_comparison
                  if (value.locationPosition != null) {
                    return LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Container(
                          height: constraints.maxHeight,
                          color: AppColors.light,
                          width: constraints.maxWidth,
                          child: GoogleMap(
                            mapType: MapType.normal,
                            zoomControlsEnabled: true,
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            polylines: Set<Polyline>.of(polylines.values),
                            markers: {
                              Marker(
                                position:
                                    LatLng(latLng.latitude, latLng.longitude),
                                markerId: MarkerId(model.driverId),
                                icon: _markerbitmapBus,
                              ),
                              Marker(
                                position: value.locationPosition,
                                markerId: MarkerId(studentName),
                                icon: _markerbitmapStudent,
                              )
                            },
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                                target:
                                    LatLng(latLng.latitude, latLng.longitude),
                                zoom: 17.5),
                          ),
                        );
                      },
                    );
                  }

                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizing.h_32),
                      child: Column(
                        children: [Text("Sorry Could not load your Location")],
                      ),
                    ),
                  );
                }),
                DraggableScrollableSheet(
                  initialChildSize: 0.2,
                  maxChildSize: 0.5,
                  minChildSize: 0.2,
                  // expand: true,
                  builder: ((BuildContext context,
                      ScrollController scrollController) {
                    return Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -AppSizing.h_16,
                            child: Container(
                              height: AppSizing.h_8,
                              width: AppSizing.h_54,
                              decoration: BoxDecoration(
                                  color: AppColors.dark,
                                  borderRadius:
                                      BorderRadius.circular(AppSizing.h_16)),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              boxShadow: [
                                BoxShadow(color: AppColors.gray, blurRadius: 1),
                              ],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppSizing.h_32),
                              ),
                            ),
                            padding: const EdgeInsets.all(AppSizing.h_16),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              physics: const ClampingScrollPhysics(),
                              controller: scrollController,
                              scrollDirection: Axis.vertical,
                              children: [
                                Text(
                                  "Buss Details",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSizing.h_24,
                                    color: AppColors.dark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: AppSizing.s_4,
                                ),
                                const SpaceComponent(
                                  factor: 5,
                                  type: TYPE.vertical,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width:
                                          AppSizing.deviceWidth(context) * 0.3,
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: AppSizing.h_16,
                                              width: AppSizing.h_16,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSizing.h_8),
                                                color: busModel.busState ==
                                                        BusState.full
                                                    ? AppColors.secondary
                                                    : AppColors.active,
                                              ),
                                            ),
                                            const SpaceComponent(
                                              factor: 20,
                                              type: TYPE.horizontal,
                                            ),
                                            SvgPicture.asset(
                                              AppImageUrls.splashImage,
                                              width: AppSizing.h_54,
                                            ),
                                          ]),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "Driver ID: ${busModel.driverId}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.light,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SpaceComponent(
                                  factor: 40,
                                  type: TYPE.vertical,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Estimated Time",
                                      style:
                                          TextStyle(fontSize: AppSizing.h_16),
                                    ),
                                    const SpaceComponent(
                                      factor: 20,
                                      type: TYPE.horizontal,
                                    ),
                                    Text(
                                      _time == "-1" ? "time" : _time,
                                      style: const TextStyle(
                                          fontSize: AppSizing.h_16),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Distance",
                                      style:
                                          TextStyle(fontSize: AppSizing.h_16),
                                    ),
                                    const SpaceComponent(
                                      factor: 20,
                                      type: TYPE.horizontal,
                                    ),
                                    if (_distance == -1)
                                      const Text("calculating ...")
                                    else
                                      Text(
                                          "${_distance.toStringAsFixed(2)} km"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Status",
                                      style: TextStyle(
                                          color: AppColors.light,
                                          fontSize: AppSizing.h_16),
                                    ),
                                    const SpaceComponent(
                                      factor: 20,
                                      type: TYPE.horizontal,
                                    ),
                                    Chip(
                                      label: Text(
                                          busModel.busState == BusState.full
                                              ? "Full"
                                              : "Not Full"),
                                      avatar: CircleAvatar(
                                          backgroundColor:
                                              busModel.busState == BusState.full
                                                  ? AppColors.secondary
                                                  : AppColors.active),
                                    )
                                  ],
                                ),
                                const SpaceComponent(
                                  factor: 40,
                                  type: TYPE.vertical,
                                ),
                                Divider(
                                  height: AppSizing.s_2,
                                  color: AppColors.gray,
                                  indent: AppSizing.h_32,
                                ),
                                const SpaceComponent(
                                  factor: 10,
                                  type: TYPE.vertical,
                                ),
                                Text(
                                  "Recent Destinations",
                                  style: TextStyle(
                                      color: AppColors.light,
                                      fontSize: AppSizing.h_16),
                                ),
                                const SpaceComponent(
                                  factor: 10,
                                  type: TYPE.vertical,
                                ),
                                bussDestinations(
                                    context, busModel.startPoint, "from"),
                                bussDestinations(
                                    context, busModel.currentDestination, "To"),
                              ],
                            ),
                          ),
                        ]);
                  }),
                )
              ],
            );
          }),
    );
  }

  BusModel _genBusModel(QueryDocumentSnapshot<Map<String, dynamic>> e,
      Map<String, dynamic> data) {
    return BusModel(
        busId: e.id,
        busNumber: data["busNumber"] ?? " ",
        destinations: data["destinations"] ?? [],
        currentDestination: data["currentDestination"] ?? " ",
        startPoint: data["startPoint"] ?? " ",
        driverId: data["driverId"] ?? " ",
        location: data["location"] == null
            ? Location(lat: 0.0, long: 0.0)
            : Location(
                lat: data["location"]["lat"], long: data["location"]["lng"]),
        busState: data["busState"] == "full" ? BusState.full : BusState.notFull,
        driverState: data["driverState"] ?? "Offline");
  }

  Container bussDestinations(
      BuildContext context, String destination, String notation) {
    return Container(
      width: AppSizing.deviceWidth(context),
      margin: const EdgeInsets.symmetric(vertical: AppSizing.h_8),
      padding: const EdgeInsets.symmetric(
          vertical: AppSizing.h_8, horizontal: AppSizing.h_24),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(AppSizing.h_32),
      ),
      child: Row(
        children: [
          Chip(
            label: Text(notation),
            avatar: CircleAvatar(
              child: SvgPicture.asset(AppImageUrls.splashImage),
            ),
          ),
          Expanded(
              child: Container(
            child: Text(
              destination,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: AppSizing.h_16),
            ),
          ))
        ],
      ),
    );
  }

  Future<void> mymap(BusModel model) async {
    await _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(model.location.lat!, model.location.long!),
          zoom: 14.5),
    ));
  }
}
