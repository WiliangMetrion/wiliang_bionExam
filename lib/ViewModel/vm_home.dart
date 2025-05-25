import 'package:covid_survey/catch_async.dart';
import 'package:covid_survey/req.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:covid_survey/View/v_map.dart';

import '../Class/cls_hospital.dart';
import '../Class/cls_province.dart';

const String url = 'https://dekontaminasi.com/api/id/covid19/hospitals';

class HomeVM extends GetxController {
  double initialSize = 0.9;
  List<Hospital> allHospital = [];
  List<Hospital> hospitals = <Hospital>[].obs;

  List<Province> provinces = <Province>[].obs;
  RxList provinceFilter = [].obs;

  @override
  void onInit() {
    determinePosition();
    load();
    hospitals = allHospital;
    super.onInit();
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Layanan lokasi telah dinonaktifkan');
      openAppSettings();
      return Future.error('Layanan lokasi telah dinonaktifkan');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Perizinan lokasi telah ditolak!');
        openAppSettings();
        return Future.error('Perizinan lokasi telah ditolak!');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Fluttertoast.showToast(
        msg: 'Perizinan lokasi non-aktif, mohon aktifkan terlebih dahulu',
      );
      openAppSettings();
      return Future.error(
        'Perizinan lokasi non-aktif, mohon aktifkan terlebih dahulu',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void getLocation(BuildContext context, String address) {
    CatchAsync.run(
      status: 'Get Location ...',
      future: () async {
        List<Location> locations = await locationFromAddress(address);

        double latitude = locations[0].latitude;
        double longitude = locations[0].longitude;

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MapView(latitude: latitude, longitude: longitude),
            ),
          );
        }
      },
    );
  }

  void load() {
    allHospital.clear();
    provinces.clear();
    provinceFilter.clear();

    List<String> listProv = [];
    update();
    CatchAsync.run(
      status: "Load data...",
      future: () async {
        var data = await Req().getData(url);

        for (var d in data) {
          allHospital.add(Hospital.fromJson(d));
          listProv.add(d['province']);
        }

        for (var a in listProv.toSet()) {
          provinces.add(Province(a, false));
        }
        update();
      },
    );
  }

  void resetFilter() {
    provinceFilter.clear();

    for (var (index, a) in provinces.indexed) {
      provinces[index].selected = false;
    }
    update();
  }

  Future<void> buildBottomSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setState,
          ) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: initialSize,
              maxChildSize: 0.9,
              minChildSize: 0.3,
              builder: (
                BuildContext context,
                ScrollController scrollController,
              ) {
                Size screen = MediaQuery.sizeOf(context);

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 0.85 * screen.height,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: double.maxFinite,
                            child: Center(
                              child: Container(
                                height: 6,
                                width: 75,
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.black12,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filter',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Obx(
                                () => Visibility(
                                  visible: provinceFilter.isNotEmpty,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() => resetFilter());
                                    },
                                    child: Text('Reset'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: CupertinoScrollbar(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  Province province = provinces[index];
                                  return ListTile(
                                    title: Text(province.name),
                                    trailing: Checkbox(
                                      value: provinces[index].selected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          initialSize = 0.9;
                                          province.selected = value!;

                                          if (value == true) {
                                            provinceFilter.add(
                                              provinces[index].name,
                                            );
                                          } else {
                                            provinceFilter.removeWhere(
                                              (text) =>
                                                  text == provinces[index].name,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (context, index) => const Divider(),
                                itemCount: provinces.length,
                              ),
                            ),
                          ),
                          FilledButton(
                            onPressed: () {
                              if (provinceFilter.isNotEmpty) {
                                hospitals =
                                    allHospital
                                        .where(
                                          (h) => provinceFilter.contains(
                                            h.province,
                                          ),
                                        )
                                        .toList();
                              } else {
                                hospitals = allHospital;
                              }
                              update();
                              Navigator.pop(context);
                            },
                            child: Text('Terapkan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
