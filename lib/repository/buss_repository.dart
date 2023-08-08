import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:project/presentation/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/bus.dart';

class BusRepository extends GetxController {
  static BusRepository get instance => Get.find();

  final _collection = "Bus";
  final _db = FirebaseFirestore.instance;

  BusModel getBusModel(Map<String, dynamic> data, String id) {
    return BusModel(
        busId: id,
        busNumber: data["busNumber"] ?? "",
        destinations: data["destinations"] ?? [],
        currentDestination: data["currentDestination"] ?? "",
        startPoint: data["startPoint"] ?? "",
        driverId: data["driverId"] ?? "",
        location: data["location"] == null
            ? Location(lat: 0.0, long: 0.0)
            : Location(
                lat: data["location"]["lat"], long: data["location"]["lng"]),
        busState: data["busState"] == "full" ? BusState.full : BusState.notFull,
        driverState: data["driverState"] ?? "Offline");
  }

  Future<BusModel> readSingleBusData(String driverId) async {
    final res = await _db
        .collection(_collection)
        .where("driverId", isEqualTo: driverId)
        .get();

    final doc = res.docs
        .map((e) {
          final data = e.data();
          final model = getBusModel(data, e.id);
          return model;
        })
        .toList()
        .first;

    return doc;
  }

  Future<List<dynamic>> readBusDestinations(String? driverId) async {
    final res = await _db
        .collection(_collection)
        .where("driverId", isEqualTo: driverId)
        .get();

    final hold = res.docs[0]["destinations"];

    final data = hold.map((e) => e.toString()).toList();

    // final data = hold.map((val) => val.toString());

    return data;
  }

  updateOrCreateBusNumber(String driverId, String busNumber) async {
    final pref = await SharedPreferences.getInstance();

    var init;

    try {
      init = pref.getString("busId");
    } catch (e) {
      init = null;
    }

    if (init != null) {
      _db.collection(_collection).doc(init).set({
        "busNumber": busNumber,
      }, SetOptions(merge: true));
    } else {
      _db.collection(_collection).add({
        "driverId": driverId,
        "busNumber": busNumber,
      }).then((value) {
        pref.setString("busId", value.id);
      });
    }
  }

  updateOrCreateBusLocation(String deriverId, Location location) async {
    final pref = await SharedPreferences.getInstance();
    final busId = pref.getString("busId");

    _db.collection(_collection).doc(busId).set({
      "location": {
        "lat": location.lat,
        "lng": location.long,
      },
    }, SetOptions(merge: true));
  }

  updateBusData(BusModel busModel, String driverId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final busId = pref.getString("busId");

    _db
        .collection(_collection)
        .doc(busId)
        .set(busModel.toJson(), SetOptions(merge: true));
  }

  Future<List<BusModel>> readAllBussData() async {
    // List<BusAndDriver> data = await BusDriverRepository().loadBusAndDriver();

    // print("-------------------- 👌❤️❤️❤️❤️😁🙌 $data");

    final res = await _db.collection(_collection).get();

    final hold = res.docs
        .where((e) =>
            e.data()["destinations"] != null &&
            e.data()["destinations"].length >= 2)
        .map((e) {
      final data = e.data();

      final results = getBusModel(data, e.id);

      return results;
    }).toList();

    return hold.where((e) {
      if (e.destinations!.isEmpty) return false;
      return true;
    }).toList();
  }

  void updateBusDataField(
      String s, List<String> snapshotStrings, String status) async {
    final pref = await SharedPreferences.getInstance();
    final busId = pref.getString("busId");

    _db.collection(_collection).doc(busId).set({
      "destinations": snapshotStrings,
    }, SetOptions(merge: true)).then((value) {
      Get.snackbar(
        "Success",
        "locations $status successfully",
        colorText: AppColors.light,
        backgroundColor: AppColors.active,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }
}
