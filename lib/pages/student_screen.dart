import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/components/bus_item_component.dart';
import 'package:project/components/spacing_component.dart';
import 'package:project/model/bus_driver.dart';
import 'package:project/controller/student_controller.dart';
import 'package:project/repository/bus_driver_repository.dart';
import 'package:project/repository/buss_repository.dart';
import 'package:project/pages/buss_detail_screen.dart';
import 'package:project/pages/sign_in_screen.dart';
import 'package:project/presentation/colors.dart';
import 'package:project/presentation/sizing.dart';
import 'package:project/presentation/strings.dart';
import 'package:project/presentation/text_theme.dart';
import 'package:location/location.dart' as loc;
import 'package:project/provider/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/bus.dart';
import '../model/auth/user.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});
  static const String routeName = "/student";

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  loc.Location location = loc.Location();
  late LatLng studentLocation;

  handleItemClick(BusModel bus, String student) async {
    Navigator.of(context).pushNamed(BussDetail.routeName,
        arguments: {"bussData": bus, "studentName": student});
  }

  final studentController = Get.put(StudentController());
  final busRepo = Get.put(BusRepository());
  late Future<UserModel> _userFuture;
  late Future<List<BusAndDriver>> _loadBusData;

  Future<UserModel> _loadDriverData() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    String email = preference.getString("email")!;

    return await studentController.loadStudentData(email);
  }

  @override
  void initState() {
    super.initState();
    Provider.of<UserLocationProvider>(context, listen: false).initialize();
    _userFuture = _loadDriverData();
    _loadBusData = _loadBusDataFuture();
  }

  @override
  void dispose() {
    Provider.of<UserLocationProvider>(context, listen: false).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserModel>(
            future: _userFuture,
            builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
              if (!snapshot.hasData) {
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

              return CustomScrollView(
                slivers: [
                  // SliverAppBar(
                  //   backgroundColor: AppColors.primary,
                  // ),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    SizedBox(
                      height: AppSizing.deviceHeight(context) - 30,
                      width: AppSizing.deviceWidth(context),
                      child: Stack(
                        children: [
                          Container(
                            height: 270,
                            color: AppColors.primary,
                            padding: const EdgeInsets.only(
                                top: AppPadding.p_16,
                                left: AppPadding.p_16,
                                right: AppPadding.p_16),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    AppImageUrls.splashImage,
                                    height: AppSizing.h_80,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "BusTrack",
                                        style: TextStyle(
                                            fontSize: AppSizing.h_24,
                                            color: AppColors.light,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Student",
                                        style: AppTextTheme.textNormalMd(
                                            color: AppColors.gray),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Expanded(
                                  child: Container(
                                width: AppSizing.deviceWidth(context),
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppPadding.p_16),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data!.userName,
                                        style: TextStyle(
                                            color: AppColors.gray,
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppSizing.h_24),
                                      ),
                                      const SpaceComponent(
                                        factor: 5,
                                        type: TYPE.vertical,
                                      ),
                                      Text(snapshot.data!.email),
                                      const SpaceComponent(
                                        factor: 3,
                                        type: TYPE.vertical,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                              onPressed: () =>
                                                  _logoutStudent(context),
                                              child: Text("Sign out")),
                                        ],
                                      )
                                    ]),
                              )),
                            ]),
                          ),
                          Positioned(
                            top: 250,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p_24,
                                  vertical: AppPadding.p_16),
                              height: AppSizing.deviceHeight(context) - 250,
                              width: AppSizing.deviceWidth(context),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24))),
                              child: FutureBuilder<List<BusAndDriver>>(
                                  future: _loadBusData,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<BusAndDriver>>
                                          busSnapshot) {
                                    if (!busSnapshot.hasData) {
                                      return const Center(
                                        child: SizedBox(
                                            height: AppSizing.h_8,
                                            child: CircularProgressIndicator()),
                                      );
                                    }

                                    if (busSnapshot.hasError) {
                                      return Center(
                                        child:
                                            Text("Error ${busSnapshot.error}"),
                                      );
                                    }

                                    if (busSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    return busSnapshot.data!.isNotEmpty
                                        ? ListView(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Available Buses",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _loadBusData =
                                                            _loadBusDataFuture();
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.refresh),
                                                    color: AppColors.gray,
                                                  ),
                                                ],
                                              ),
                                              for (BusAndDriver model
                                                  in busSnapshot.data!)
                                                GestureDetector(
                                                  onTap: model.bus
                                                                  .startPoint !=
                                                              "" &&
                                                          model.bus
                                                                  .currentDestination !=
                                                              "" &&
                                                          model.bus
                                                                  .driverState !=
                                                              "Offline"
                                                      ? () => handleItemClick(
                                                          model.bus,
                                                          snapshot
                                                              .data!.userName)
                                                      : () {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                                      content:
                                                                          Text(
                                                            "🙏🙏Sorry the bus is currently inactive. Please try again latter. Thank you.",
                                                            softWrap: true,
                                                            textAlign: TextAlign.center,
                                                          )));
                                                        },
                                                  child: BusItem(
                                                      busAndDriverModel: model),
                                                )
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Oooh... \n Sory No Buses have been registered yet",
                                                style: TextStyle(
                                                    fontSize: AppSizing.h_24,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.dark),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(
                                                height: AppSizing.h_24,
                                              ),
                                              Text("Let's come back later"),
                                              Container(
                                                height: AppSizing.h_8,
                                                width: AppSizing.h_54,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppSizing.h_32),
                                                    color: AppColors.secondary),
                                              ),
                                            ],
                                          );
                                  }),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Container(
                    //   height: AppSizing.h_250,
                    //   decoration: BoxDecoration(color: AppColors.primary),
                    //   child: const Column(
                    //     children: [
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [Text("Dacosta"), Text("#Student")],
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   height: 1000,
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.only(
                    //           topLeft: Radius.circular(AppSizing.h_8),
                    //           topRight: Radius.circular(AppSizing.h_8))),
                    //   padding: EdgeInsets.all(AppPadding.p_8),
                    //   child: ListView.builder(
                    //     padding: EdgeInsets.zero,
                    //     itemBuilder: (BuildContext context, i) {
                    //       return const BussItem();
                    //     },
                    //     itemCount: 100,
                    //   ),
                    // )
                  ]))
                ],
              );
            }),
      ),
    );
  }

  Future<List<BusAndDriver>> _loadBusDataFuture() =>
      BusDriverRepository().loadBusAndDriver();

  _logoutStudent(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove("email");
    pref.remove("userType");
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
    });
  }
}
