import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/model/bus.dart';
import 'package:project/model/bus_driver.dart';
import 'package:project/model/auth/user.dart';

class BusDriverRepository {
  final _driverCollection = "Users";
  final _busCollection = "Bus";

  final _instance = FirebaseFirestore.instance;

  Future<List<BusAndDriver>> loadBusAndDriver() async {
    final res = await _instance.collection(_busCollection).get();

    List<BusModel> buses = res.docs.map((e) {
      final data = e.data();
      return BusModel(
          busId: e.id,
          busNumber: data["busNumber"] ?? "",
          destinations: data["destinations"] ?? [],
          currentDestination: data["currentDestination"] ?? "",
          startPoint: data["startPoint"] ?? "",
          driverId: data["driverId"] ?? "",
          location: data["location"] == null
              ? Location(lat: 0.0, long: 0.0)
              : Location(
                  lat: data["location"]["lat"], long: data["location"]["lng"]),
          busState:
              data["busState"] == "full" ? BusState.full : BusState.notFull,
          driverState: data["driverState"] ?? 'Offline');
    }).toList();

    print("-----------------got here❤️❤️❤️❤️❤️👌😂😂 #1");

    final userRes = await _instance.collection(_driverCollection).get();

    print("-----------------got here❤️❤️❤️❤️❤️👌😂😂 #2");

    List<UserModel> users =
        userRes.docs.where((e) => e.data()["user_type"] == "driver").map((e) {
      final data = e.data();
      print("-----------------got here❤️❤️❤️❤️❤️👌😂😂 #3");

      return UserModel(
          userId: e.id,
          userName: data["userName"],
          password: "",
          email: data["email"],
          userType: "userType");
    }).toList();

    return buses.map((e) {
      final user = users.where((user) => user.userId == e.driverId).first;
      return BusAndDriver(bus: e, user: user);
    }).toList();
  }
}
