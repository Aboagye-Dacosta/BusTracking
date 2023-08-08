import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/model/bus_driver.dart';
import 'package:project/presentation/colors.dart';
import 'package:project/presentation/sizing.dart';

import '../model/bus.dart';

class BusItem extends StatelessWidget {
  final BusAndDriver busAndDriverModel;
  const BusItem({super.key, required this.busAndDriverModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizing.h_8),
      width: AppSizing.deviceWidth(context),
      padding: const EdgeInsets.symmetric(
          vertical: AppPadding.p_16, horizontal: AppFontSizes.fs_16),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: AppColors.gray, blurRadius: 0)],
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bus Driver: ${busAndDriverModel.user.userName.capitalize}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: AppSizing.h_16),
            ),
            Text(
              "Plate: ${busAndDriverModel.bus.busNumber!}",
              style: TextStyle(
                color: AppColors.gray,
              ),
            ),
            if (busAndDriverModel.bus.startPoint.isNotEmpty)
              Column(
                children: [
                  const SizedBox(
                    height: AppSizing.h_8,
                  ),
                  _locationTile(
                      type: "Start Point",
                      value: busAndDriverModel.bus.startPoint),
                ],
              ),
            if (busAndDriverModel.bus.currentDestination.isNotEmpty)
              Column(
                children: [
                  _locationTile(
                      type: "Destination",
                      value: busAndDriverModel.bus.currentDestination),
                  const SizedBox(
                    height: AppSizing.h_8,
                  ),
                ],
              ),
            Row(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: AppSizing.h_16,
                        width: AppSizing.h_16,
                        margin: EdgeInsets.only(right: AppSizing.s_4),
                        decoration: BoxDecoration(
                            color:
                                busAndDriverModel.bus.driverState == "Offline"
                                    ? AppColors.secondary
                                    : AppColors.active,
                            borderRadius: BorderRadius.circular(AppSizing.h_8)),
                      ),
                      Text(busAndDriverModel.bus.driverState == "Offline"
                          ? "Inactive"
                          : "Active")
                    ]),
                const SizedBox(
                  width: AppSizing.h_24,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: AppSizing.h_16,
                        width: AppSizing.h_16,
                        margin: EdgeInsets.only(right: AppSizing.s_4),
                        decoration: BoxDecoration(
                            color:
                                busAndDriverModel.bus.busState == BusState.full
                                    ? AppColors.secondary
                                    : AppColors.active,
                            borderRadius: BorderRadius.circular(AppSizing.h_8)),
                      ),
                      Text(busAndDriverModel.bus.busState == BusState.full
                          ? "Full"
                          : "Not Full")
                    ]),
              ],
            )
          ]),
    );
  }

  Row _locationTile({required String type, required String value}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              vertical: AppSizing.s_2, horizontal: AppSizing.s_4),
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizing.s_4)),
          child: Text(
            type,
            style: TextStyle(fontSize: AppSizing.h_8, color: AppColors.light),
          ),
        ),
        SizedBox(
          width: AppPadding.p_16,
        ),
        Text(value)
      ],
    );
  }
}
