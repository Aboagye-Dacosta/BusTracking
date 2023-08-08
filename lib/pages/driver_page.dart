import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:project/components/button_component.dart';
import 'package:project/components/spacing_component.dart';
import 'package:project/model/bus.dart';
import 'package:project/pages/destinations_page.dart';
import 'package:project/pages/sign_in_screen.dart';
import 'package:project/presentation/colors.dart';
import 'package:project/presentation/sizing.dart';
import 'package:project/presentation/strings.dart';
import 'package:project/presentation/text_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;

import '../model/auth/user.dart';
import '../controller/driver_controller.dart';
import '../repository/buss_repository.dart';
import '../provider/location_provider.dart';

String? _radioState = "initial";
String? _startPoint = "initial";
String? _destination = "initial";
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
  late bool isBusAdded = false;
  late bool isLoading = false;

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
    driverData = _loadDriverData();
    loadFuture = _loadDestinations();
    Provider.of<UserLocationProvider>(context, listen: false).initialize();
  }

  @override
  Widget build(BuildContext context) {
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

          final busModel = BusModel(
              driverState: active ? "Online" : "Offline",
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

    void onTapBussState(String? value) {
      setState(() {
        _radioState = value;
      });
    }

    void onTapStartPoint(String? value) {
      setState(() {
        _startPoint = value;
      });
    }

    void onTapDestination(String? value) {
      setState(() {
        _destination = value;
      });
    }

    void handleSignOut() async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove("email");
      pref.remove("userType");
      setState(() {
        active = false;
        if (_locationSubscription != null) {
          _locationSubscription!.cancel();
        }
      });
      if (_locationSubscription != null) {
        Future.delayed(Duration(seconds: 3), () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
          });
        });
      } else {
        FirebaseAuth.instance.signOut().then((value) {
          Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
        });
      }
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

    // void (List<dynamic> list, String str) {
    //   final li = list.map((e) => e.toString()).toList();
    //   li.remove(str);

    //   bussRepo.updateBusDataField("destinations", li);

    //   setState(() {
    //     loadFuture = _loadDestinations();
    //   });
    // }

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
                                _radioTile(
                                  value: "full",
                                  label: "Buss Full",
                                  groupValue: _radioState,
                                  onTap: () => onTapBussState("full"),
                                  onChanged: onTapBussState,
                                ),
                                _radioTile(
                                  value: "not full",
                                  label: "Bus not full",
                                  groupValue: _radioState,
                                  onTap: () => onTapBussState("space"),
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
                            // ClipRRect(
                            //   borderRadius: BorderRadius.circular(AppSizing.h_24),
                            //   child: ButtonComponent(
                            //     label: "save",
                            //     handler: handleSave,
                            //   ),
                            // )
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
                                              .map((val) => _radioTile(
                                                    value: val,
                                                    label: val,
                                                    groupValue: _startPoint,
                                                    onTap: () =>
                                                        onTapStartPoint(val),
                                                    onChanged: onTapStartPoint,
                                                  ))
                                              .toList()
                                        ]
                                      : [],
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
                                              .map((val) => _radioTile(
                                                    value: val,
                                                    label: val,
                                                    groupValue: _destination,
                                                    onTap: () =>
                                                        onTapDestination(val),
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
                                      Text("Destinations should be at lest 2"),
                                      SizedBox(
                                        height: AppSizing.h_8,
                                      ),
                                      Text(
                                        "Please your destination list.",
                                        style: TextStyle(
                                          fontSize: AppSizing.h_16,
                                          color: AppColors.gray,
                                        ),
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
                      label: "Add destination",
                      handler: () =>
                          handleAddDestinations(driverSnapshot.data!.userId!),
                    ),
                  ),
                )
              ]);
        });
  }

  _radioTile({
    String value = "",
    String label = "",
    String? groupValue,
    void Function()? onTap,
    void Function(String?)? onChanged,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        child: Container(
          // width: AppSizing.h_120,
          padding: const EdgeInsets.symmetric(horizontal: AppSizing.h_8),
          margin: const EdgeInsets.all(AppSizing.s_2),

          decoration: BoxDecoration(
              color: groupValue == value ? AppColors.primary : AppColors.light,
              border: Border.all(
                  width: 1.0,
                  color: groupValue == value ? AppColors.primary : Colors.grey),
              borderRadius: BorderRadius.circular(AppSizing.h_54)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Radio(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                toggleable: true,
              ),
              Text(
                label,
                style: TextStyle(
                    color:
                        groupValue == value ? AppColors.light : AppColors.dark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(
      BuildContext context, String driverId, bool isBusAdded) {
    String input1 = '';
    String input2 = '';

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
              isBusAdded
                  ? TextField(
                      onChanged: (value) {
                        input2 = value;
                      },
                      decoration: InputDecoration(labelText: 'Driver Id'),
                    )
                  : const SizedBox(),
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
  }
}
