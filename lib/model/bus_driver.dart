import 'package:project/model/bus.dart';
import 'package:project/model/auth/user.dart';

class BusAndDriver {
  final BusModel bus;
  final UserModel user;

  BusAndDriver({required this.bus, required this.user});

  @override
  String toString() => "{\nBusId: ${bus.busId};\nDriverId: ${user.userId}\n}";
}
