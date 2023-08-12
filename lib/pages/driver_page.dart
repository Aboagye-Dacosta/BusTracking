import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:project/components/button_component.dart';
import 'package:project/components/radio_tile.dart';
import 'package:project/components/spacing_component.dart';
import 'package:project/model/bus.dart';
import 'package:project/pages/destinations_page.dart';
import 'package:project/pages/sign_in_screen.dart';
import 'package:project/presentation/colors.dart';
import 'package:project/presentation/sizing.dart';
import 'package:project/presentation/strings.dart';
import 'package:project/presentation/text_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/driver_controller.dart';
import '../model/auth/user.dart';
import '../repository/buss_repository.dart';

String? _radioState = "initial";
String? _startPoint = "start";
String? _destination = "destination";
String currentDestination = "";
String currentStartPoint = "";
bool active = false;

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});
  static const String routeName = "driver";

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  late Future<List<dynamic>> loadFuture;
  late Future<UserModel> driverData;
  final driverController = Get.put(DriverController());
  final bussRepo = Get.put(BusRepository());
  bool isEditable = false;
  final loc.Location location = loc.Location();
  bool isBusAdded = false;
  bool isLoading = false;

  late StreamSubscription<loc.LocationData>? _locationSubscription = null;

  Future<UserModel> _loadDriverData() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    try {
      isBusAdded = preference.getBool("isBusAdded")!;
    } catch (e) {}
    String email = preference.getString("email")!;
    return await driverController.loadDriverData(email);
  }

  Future<List<dynamic>> _loadDestinations() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userId = pref.getString("userId") as String;
    return await bussRepo.readBusDestinations(userId);
  }

  @override
  void initState() {
    super.initState();
    _handlePermission();
    driverData = _loadDriverData();
    loadFuture = _loadDestinations();
  }

  @override
  Widget build(BuildContext context) {
    void onTapBussState(String? value) {
      setState(() {
        if (value == null) value = "initial";
        _radioState = value;
      });
    }

    void onTapStartPoint(String? value) {
      setState(() {
        if (value == null) value = "startPoint";
        _startPoint = value;
        currentStartPoint = value!;
      });
    }

    void onTapDestination(String? value) {
      setState(() {
        if (value == null) value = "destination";
        _destination = value;
        currentDestination = value!;
      });
    }

    void handleSignOut() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove("email");
      pref.remove("userType");

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      setState(() {
        active = false;
      });
      await bussRepo.updateBusDataDriverState("Offline");

      Future.delayed(Duration(seconds: 3), () {
        FirebaseAuth.instance.signOut().then((value) {
          Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
        });
      });
    }

    void handleForm(String driverId, bool isBusAdded) {
      _showAlertDialog(context, driverId, isBusAdded);
    }

    void handleEditLocations() {
      setState(() {
        isEditable = !isEditable;
      });
    }

    void handleAddDestinations(String? str) {
      Navigator.of(context).pushNamed(DestinationPage.routName, arguments: str);
    }

    return Scaffold(
        body: FutureBuilder<UserModel>(
      future: driverData,
      builder: (BuildContext context, AsyncSnapshot<UserModel> driverSnapshot) {
        if (!driverSnapshot.hasData) {
          return SizedBox(
            height: AppSizing.deviceHeight(context),
            width: AppSizing.deviceWidth(context),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: AppSizing.s_4,
                ),
                Text("loading ...")
              ],
            ),
          );
        }
        if (driverSnapshot.hasData) {
          return Stack(
            children: [
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSizing.h_54, horizontal: AppSizing.h_24),
                  height: constraints.maxHeight * 0.6,
                  color: AppColors.primary,
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            AppImageUrls.splashImage,
                            width: AppSizing.h_80,
                          ),
                          Text(
                            AppStrings.splashScreenMainText,
                            style: AppTextTheme.textNormalMd(
                                color: AppColors.light,
                                fontSize: AppSizing.h_24),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: AppPadding.p_8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Buss Id",
                            style: TextStyle(
                                fontSize: AppFontSizes.fs_16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray),
                          ),
                          Text(
                            "783828IU77",
                            style: TextStyle(
                                fontSize: AppFontSizes.fs_16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray),
                          ),
                        ],
                      ),
                      const SpaceComponent(
                        factor: 70,
                        type: TYPE.vertical,
                      ),
                      Text(
                        "Driver Name",
                        style: TextStyle(
                          fontSize: AppSizing.h_16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray,
                        ),
                      ),
                      const SizedBox(
                        height: AppSizing.h_8,
                      ),
                      Text(
                        driverSnapshot.data!.userName,
                        style: TextStyle(
                          fontSize: AppSizing.h_32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.light,
                        ),
                      ),
                      Text(driverSnapshot.data!.email),
                      const SizedBox(
                        height: AppFontSizes.fs_24,
                      ),
                      const SpaceComponent(
                        factor: 5,
                        type: TYPE.vertical,
                      ),
                      Align(
                          alignment: Alignment.topRight,
                          child: FittedBox(
                              child: TextButton(
                                  onPressed: handleSignOut,
                                  child: Text("Sign out"))))
                    ],
                  ),
                );
              }),
              DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.5,
                  maxChildSize: 0.8,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSizing.h_24, horizontal: AppSizing.h_16),
                      decoration: BoxDecoration(
                          color: AppColors.light,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppSizing.h_32))),
                      child: ListView(
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          clipBehavior: Clip.antiAlias,
                          controller: scrollController,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        loadFuture = _loadDestinations();
                                      });
                                    },
                                    icon: Icon(Icons.refresh)),
                                TextButton(
                                  onPressed: () async {
                                    if (!isBusAdded) {
                                      SharedPreferences pre =
                                          await SharedPreferences.getInstance();
                                      pre.setBool("isBusAdded", true);
                                    }
                                    handleForm(driverSnapshot.data!.userId!,
                                        isBusAdded);
                                  },
                                  child: isBusAdded
                                      ? const Text("update bus details")
                                      : const Text("Add bus detail"),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: AppSizing.h_54),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        active ? "Online" : "Offline",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppSizing.h_24),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        handleTap(driverSnapshot.data!.userId!),
                                    child: Container(
                                      height: AppSizing.h_120,
                                      width: AppSizing.h_120,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? AppColors.active
                                            : AppColors.secondary,
                                        borderRadius: BorderRadius.circular(
                                          AppSizing.h_120 * 0.5,
                                        ),
                                      ),
                                      child: Center(
                                          child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.power_settings_new,
                                            size: AppSizing.h_54,
                                            color: active
                                                ? AppColors.dark
                                                : AppColors.light,
                                          ),
                                          if (isLoading)
                                            CircularProgressIndicator()
                                        ],
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text("Choose Buss State",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SpaceComponent(
                              factor: 10,
                              type: TYPE.vertical,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                RadioTile(
                                  value: "full",
                                  label: "Buss Full",
                                  groupValue: _radioState,
                                  onTap: () => onTapBussState("full"),
                                  onChanged: onTapBussState,
                                ),
                                RadioTile(
                                  value: "not full",
                                  label: "Bus not full",
                                  groupValue: _radioState,
                                  onTap: () => onTapBussState("not full"),
                                  onChanged: onTapBussState,
                                )
                              ],
                            ),
                            const SpaceComponent(
                              factor: 40,
                              type: TYPE.vertical,
                            ),
                            Divider(
                              color: AppColors.gray,
                              height: AppSizing.s_2,
                            ),
                            const SpaceComponent(
                              factor: 40,
                              type: TYPE.vertical,
                            ),
                            _locationBuild(
                                driverSnapshot,
                                onTapStartPoint,
                                onTapDestination,
                                handleEditLocations,
                                handleAddDestinations,
                                loadFuture,
                                isEditable),
                            const SpaceComponent(
                              factor: 20,
                              type: TYPE.vertical,
                            ),
                          ]),
                    );
                  })
            ],
          );
        } else if (driverSnapshot.hasError) {
          return Card(
            color: AppColors.secondary,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                  vertical: AppSizing.h_24, horizontal: AppSizing.h_16),
              child: Text("Sorry something happened"),
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    ));
  }

  FutureBuilder<List<dynamic>> _locationBuild(
      AsyncSnapshot<UserModel> driverSnapshot,
      void Function(String? value) onTapStartPoint,
      void Function(String? value) onTapDestination,
      void Function() handleEditLocations,
      void Function(String str) handleAddDestinations,
      Future<List<dynamic>> load,
      bool isEditable) {
    return FutureBuilder<List<dynamic>>(
        future: load,
        builder: (context, AsyncSnapshot<List<dynamic>> destinationSnapshot) {
          if (destinationSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (destinationSnapshot.hasError) {
            return Center(
              child: Text("Error ${destinationSnapshot.error}"),
            );
          } else if (!destinationSnapshot.hasData) {
            return const Center(
              child: Text("No Destinations created"),
            );
          }
          if (destinationSnapshot.data == null) return Container();

          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...destinationSnapshot.data!.isEmpty
                    ? [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("You have not add any destinations yet"),
                            SizedBox(
                              height: AppSizing.h_8,
                            ),
                            Text(
                              "Let's get you up to speed by add some.",
                              style: TextStyle(
                                fontSize: AppSizing.h_16,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        )
                      ]
                    : [
                        ...destinationSnapshot.data!.length >= 2
                            ? [
                                Text("Choose Current Location",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SpaceComponent(
                                  factor: 10,
                                  type: TYPE.vertical,
                                ),
                                Wrap(
                                  direction: Axis.horizontal,
                                  clipBehavior: Clip.antiAlias,
                                  spacing: AppPadding.p_8,
                                  runSpacing: AppSizing.h_8,
                                  children: destinationSnapshot.hasData
                                      ? [
                                          ...destinationSnapshot.data!
                                              .map((val) => RadioTile(
                                                    value: val,
                                                    label: val,
                                                    groupValue: _startPoint,
                                                    disabled:
                                                        currentDestination ==
                                                            val,
                                                    onTap: () {
                                                      if (currentDestination !=
                                                          val)
                                                        onTapStartPoint(val);
                                                    },
                                                    onChanged: onTapStartPoint,
                                                  ))
                                              .toList()
                                        ]
                                      : [Container()],
                                ),
                                const SpaceComponent(
                                  factor: 40,
                                  type: TYPE.vertical,
                                ),
                                Text(
                                  "Choose Destination",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                                const SpaceComponent(
                                  factor: 10,
                                  type: TYPE.vertical,
                                ),
                                Wrap(
                                  direction: Axis.horizontal,
                                  clipBehavior: Clip.antiAlias,
                                  spacing: AppPadding.p_8,
                                  runSpacing: AppSizing.h_8,
                                  children: destinationSnapshot.hasData
                                      ? [
                                          ...destinationSnapshot.data!
                                              .map((val) => RadioTile(
                                                    value: val,
                                                    label: val,
                                                    groupValue: _destination,
                                                    disabled:
                                                        currentStartPoint ==
                                                            val,
                                                    onTap: () {
                                                      if (currentStartPoint !=
                                                          val)
                                                        onTapDestination(val);
                                                    },
                                                    onChanged: onTapDestination,
                                                  ))
                                              .toList()
                                        ]
                                      : [],
                                ),
                              ]
                            : [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppStrings.destinationPage_minimum,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: AppSizing.h_8,
                                      ),
                                      Text(
                                        AppStrings.destination_list_add,
                                        style: TextStyle(
                                          fontSize: AppSizing.h_16,
                                          color: AppColors.gray,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              ]
                      ],
                const SizedBox(
                  height: AppSizing.h_24,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizing.h_32),
                    child: ButtonComponent(
                      label: AppStrings.add_destination,
                      handler: () =>
                          handleAddDestinations(driverSnapshot.data!.userId!),
                    ),
                  ),
                )
              ]);
        });
  }

  void handleTap(String userId) async {
    if (_radioState != "initial" &&
        _destination != "destination" &&
        _startPoint != "startPoint" &&
        isBusAdded) {
      setState(() {
        isLoading = true;
      });
      if (!active) {
        final currentLocation = await location.getLocation();

        print("------------------------- value of active ❤️❤️❤️👌😊 $active");

        final busModel = BusModel(
            driverState: "Online",
            busState: _radioState == "full" ? BusState.full : BusState.notFull,
            currentDestination: _destination!,
            location: Location(
                lat: currentLocation.latitude!,
                long: currentLocation.longitude!),
            driverId: userId,
            startPoint: _startPoint!);

        await bussRepo.updateBusData(busModel, userId);

        _locationSubscription = location.onLocationChanged.handleError((error) {
          setState(() {
            _locationSubscription;
          });
        }).listen((loc.LocationData currentLocation) {
          bussRepo.updateOrCreateBusLocation(
            userId,
            Location(
                lat: currentLocation.latitude!,
                long: currentLocation.longitude!),
          );
        });
      } else {
        await bussRepo.updateBusDataDriverState("Offline");
        _locationSubscription!.cancel();
      }
      setState(() {
        isLoading = false;
        active = !active;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Bus State, Current Location and Destination should be selected first"),
      ));
    }
  }

  void _showAlertDialog(
      BuildContext context, String driverId, bool isBusAdded) {
    String input1 = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Bas Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  input1 = value;
                },
                decoration: InputDecoration(labelText: "Bus Plate Number"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (input1.isNotEmpty) {
                  bussRepo.updateOrCreateBusNumber(driverId, input1);
                  Navigator.of(context).pop();
                } else {
                  // Show validation error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Both inputs are required.'),
                    ),
                  );
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: const Text('save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent),
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  _handlePermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
    } else if (status.isDenied) {
      _handlePermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    void handleTap(String userId) async {
      if (_radioState != "initial" &&
          _destination != "initial" &&
          _startPoint != "initial" &&
          isBusAdded) {
        setState(() {
          isLoading = true;
        });
        if (!active) {
          final currentLocation = await location.getLocation();

          print("------------------------- value of active ❤️❤️❤️👌😊 $active");

          final busModel = BusModel(
              driverState: "Online",
              busState:
                  _radioState == "full" ? BusState.full : BusState.notFull,
              currentDestination: _destination!,
              location: Location(
                  lat: currentLocation.latitude!,
                  long: currentLocation.longitude!),
              driverId: userId,
              startPoint: _startPoint!);

          await bussRepo.updateBusData(busModel, userId);

          _locationSubscription =
              location.onLocationChanged.handleError((error) {
            setState(() {
              _locationSubscription;
            });
          }).listen((loc.LocationData currentLocation) {
            bussRepo.updateOrCreateBusLocation(
              userId,
              Location(
                  lat: currentLocation.latitude!,
                  long: currentLocation.longitude!),
            );
          });
        } else {
          await bussRepo.updateBusDataDriverState("Offline");
          _locationSubscription!.cancel();
        }
        setState(() {
          isLoading = false;
          active = !active;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Bus State, Current Location and Destination should be selected first"),
        ));
      }
    }
  }
}
