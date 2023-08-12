import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:project/components/button_component.dart';
import 'package:project/presentation/sizing.dart';
import 'package:project/presentation/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/buss_repository.dart';
import '../presentation/colors.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage({super.key});

  static const routName = "/destinations";

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  List<String> inputStrings = [];
  List<String> snapshotStrings = [];
  late Future<List<dynamic>> _loadDestinationsFuture;
  final TextEditingController _inputController = TextEditingController();

  bool isEditing = false;
  final busRepo = Get.put(BusRepository());

  void _addInputString(String input) {
    final bool test = [...inputStrings, ...snapshotStrings]
            .where((val) => val.toLowerCase() == input.toLowerCase())
            .length >
        0;

    if (test) {
      Get.snackbar("Info",AppStrings.destinationPage_exist,
          backgroundColor: Colors.yellowAccent,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      setState(() {
        inputStrings.add(input);
        _inputController.clear();
      });
    }
  }

  void _removeInputString(String input) {
    setState(() {
      inputStrings.remove(input);
    });
  }

  void _removeInputStringFromStore(String input) {
    setState(() {
      snapshotStrings.remove(input);
      _loadDestinationsFuture = _loadDestinationData();
    });

    busRepo.updateBusDataField("destinations", snapshotStrings, "deleted");
  }

  void _submitData() {
    // Here, you can handle submitting data to a collection

    if (inputStrings.isEmpty) {
      Get.snackbar("Info", AppStrings.destinationPage_add,
          backgroundColor: Colors.yellowAccent,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      setState(() {
        snapshotStrings = [...snapshotStrings, ...inputStrings];
        _loadDestinationsFuture = _loadDestinationData();
      });

      busRepo.updateBusDataField("destinations", snapshotStrings, "added");
      inputStrings.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDestinationsFuture = _loadDestinationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinations'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AppSizing.h_16, horizontal: AppSizing.h_24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.add_destination,
                  style: TextStyle(
                    fontSize: AppSizing.h_24,
                    fontWeight: FontWeight.w700,
                  )),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  for (String input in inputStrings)
                    Chip(
                        label: Text(input),
                        onDeleted: () {
                          _removeInputString(input);
                        }),
                ],
              ),
              const SizedBox(
                height: AppSizing.h_24,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration:
                          InputDecoration(labelText: 'Enter destination'),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_inputController.text.isNotEmpty) {
                        _addInputString(_inputController.text);
                      }
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizing.h_32),
                child: ButtonComponent(
                  handler: _submitData,
                  label: 'Save',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: AppSizing.h_24),
                child: Row(
                  children: [
                    const Text('Destinations'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                      child: Text(isEditing ? 'Done' : 'Edit'),
                    )
                  ],
                ),
              ),
              const SizedBox(height: AppSizing.h_16),
              FutureBuilder(
                  future: _loadDestinationsFuture,
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error ${snapshot.error}"),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(AppStrings.destinationPage_not_add),
                      );
                    }
                    snapshotStrings =
                        snapshot.data!.map((e) => e.toString()).toList();
                    return snapshot.data!.isNotEmpty
                        ? Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              for (String input in snapshot.data!)
                                Chip(
                                  label: Text(input),
                                  onDeleted: isEditing
                                      ? () {
                                          _removeInputStringFromStore(input);
                                        }
                                      : null,
                                ),
                              Container(
                                margin:
                                    const EdgeInsets.only(top: AppSizing.h_24),
                                width: double.infinity,
                                child: Column(children: [
                                  SizedBox(
                                    height: AppSizing.h_24,
                                  ),
                                  Center(
                                    child: Text(
                                      AppStrings.destinationPage_minimum,
                                      style:
                                          TextStyle(fontSize: AppSizing.h_16),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ]),
                              )
                            ],
                          )
                        : Container(
                            margin: const EdgeInsets.only(top: AppSizing.h_32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(AppStrings.destinationPage_not_add),
                                SizedBox(
                                  height: AppSizing.h_8,
                                ),
                                Text(
                                  AppStrings.destinationPage_add_some,
                                  style: TextStyle(
                                    fontSize: AppSizing.h_16,
                                    color: AppColors.gray,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> _loadDestinationData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String driverId = pref.getString("userId")!;
    return busRepo.readBusDestinations(driverId);
  }
}
