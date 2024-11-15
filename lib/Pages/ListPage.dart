import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mwpaapp/Components/DynInput.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Dialog/ConfirmDialog.dart';
import 'package:mwpaapp/Dialog/InfoDialog.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Mwpa/MwpaException.dart';
import 'package:mwpaapp/Pages/EditSightingPage.dart';
import 'package:mwpaapp/Pages/List/ListSightingTile.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Services/ThemeService.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilDate.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'List/ListMap.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

/// ListPage
class ListPage extends StatefulWidget {

  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

/// _ListPageState
class _ListPageState extends State<ListPage> {
  final PrefController _prefController = Get.find<PrefController>();
  final LocationController _locationController = Get.put(LocationController());
  final SightingController _sightingController = Get.put(SightingController());
  final VehicleController _vehicleController = Get.put(VehicleController());
  final VehicleDriverController _vehicleDriverController = Get.put(VehicleDriverController());
  final SpeciesController _speciesController = Get.put(SpeciesController());
  final EncounterCategoriesController _encounterCategoriesController = Get.put(EncounterCategoriesController());
  final BehaviouralStateController _behaviouralStateController = Get.put(BehaviouralStateController());

  late StreamSubscription subscription;

  bool diffTourDateIgnored = false;
  bool isSyncInProgress = false;
  String statusTitle = "Tour: default date is not set";

  /// initState
  @override
  void initState() {
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen(
        _syncCheckConnectivity
    );
  }

  /// dispose
  @override
  void dispose() {
    subscription.cancel();

    super.dispose();
  }

  /// _syncCheckConnectivity
  _syncCheckConnectivity(ConnectivityResult result) async {
    final hasInternet = result != ConnectivityResult.none;

    if (hasInternet) {
      if (_sightingController.sightingList.isNotEmpty) {
        _syncMwpa();
      }
    }
  }

  /// _syncMwpa
  _syncMwpa() async {
    if (isSyncInProgress) {
      return;
    }

    EasyLoading.instance.dismissOnTap = false;
    EasyLoading.instance.maskType = EasyLoadingMaskType.black;

    SyncMwpaService service = SyncMwpaService();

    try {
      isSyncInProgress = true;

      await service.sync((p0, p1) async {
        EasyLoading.showProgress(p0.round() / 100, status: '$p1 ... ${p0.round()}%');
      });

      await _vehicleController.getVehicle();
      await _vehicleDriverController.getVehicleDriver();
      await _speciesController.getSpecies();
      await _encounterCategoriesController.getEncounterCategorie();
      await _behaviouralStateController.getBehaviouralStates();
      await _locationController.reloadSettings();

      isSyncInProgress = false;
      EasyLoading.dismiss();
    } catch(error) {
      isSyncInProgress = false;
      EasyLoading.dismiss();

      if (error is MwpaException) {
        InfoDialog.show(context, 'Error', error.toString());
      } else {
        InfoDialog.show(context, 'Internal Error', error.toString());
      }
    }

    setState(() { });
  }

  /// _loadController
  _loadController() async {
    _locationController.updateEvent.removeListener(_updateTitle);
    _locationController.updateEvent.addListener(_updateTitle);

    await _speciesController.getSpecies();
    await _vehicleController.getVehicle();
    await _vehicleDriverController.getVehicleDriver();
    await _encounterCategoriesController.getEncounterCategorie();
    await _behaviouralStateController.getBehaviouralStates();
    await _locationController.reloadSettings();

    _sightingController.getSightings();
  }

  /// _logout
  _logout() async {
    ConfirmDialog.show(context, "Logout", "Do you want to logout?", (p0) async {
      if (p0 == "ok") {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove(Preference.PASSWORD);
        prefs.remove(Preference.USERID);

        await Get.toNamed('/Login');
      }
    });
  }

  /// _setEndTour
  _setEndTour(BuildContext context) {
    ConfirmDialog.show(
      context,
      "Tour End",
      "Update the tour end time for all sighting entries from the current tour?",
      (value) async {
        if (value == "ok") {
          if (_prefController.prefToru != null) {
            UtilSighting.setCurrentEndTour(UtilTourFid.createTTourFId(_prefController.prefToru!));
            _loadController();
          } else {
            if (kDebugMode) {
              print("_ListPageState:_setEndTour - prefToru is empty!");
            }
          }
        }
      }
    );
  }

  /// _appBar
  _appBar() {
    return AppBar(
      backgroundColor: kPrimaryHeaderColor,
      leading: IconButton(
        onPressed: () {
          setState(() {
            ThemeService().switchTheme();
          });
        },
        icon: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
        )
      ),
      actions: [
        DefaultButton(
            buttonIcon: Icons.post_add,
            label: 'Add Sighting',
            onTab: () async {
              await Get.toNamed('/Edit');
              _sightingController.getSightings();
            }
        ),
        PopupMenuButton(itemBuilder: (context) {
          var list = <PopupMenuEntry<Object>>[];
          list.add(
            const PopupMenuItem(
                value: "settour",
                child: Text("Set default Tour")
            ),
          );

          list.add(
              const PopupMenuDivider(
                height: 10,
              )
          );

          list.add(
            const PopupMenuItem(
                value: "sync",
                child: Text("Sync with Server")
            ),
          );

          list.add(
              const PopupMenuDivider(
                height: 10,
              )
          );

          list.add(
              const PopupMenuItem(
                value: "logout",
                child: Text("Logout"),
              )
          );
          return list;
        },
        icon: const Icon(
          Icons.person,
          color: kButtonFontColor,
        ),
        initialValue: "0",
        onSelected: (value) async {
          switch (value) {
            case "settour":
              await Get.toNamed('/setTour');
              _sightingController.getSightings();
              break;

            case "sync":
              _syncMwpa();
              break;

            case "logout":
              _logout();
              break;
          }
        },
        )
      ],
    );
  }

  /// _addShortSighting
  _addShortSighting(String otherName, BuildContext context) async {
    DynInputValue tOD = DynInputValue();
    tOD.timeValue = TimeOfDay.now();
    Position pos = _locationController.currentPosition!;
    String location = jsonEncode(pos.toJson());
    var distance = UtilDistanceCoast.getDistance(pos);

    if (_prefController.prefToru == null) {
      if (kDebugMode) {
        print("_ListPageState:_addShortSighting - prefToru is empty!");
      }

      InfoDialog.show(
          context,
          "Error",
          "Please set the standard tour dates beforehand. The entry cannot be added until then."
      );

      return;
    }

    await _sightingController.addSighting(newSighting: Sighting(
      unid: '',
      tour_fid: UtilTourFid.createTTourFId(_prefController.prefToru!),
      vehicle_id: _prefController.prefToru!.vehicle_id!,
      vehicle_driver_id: _prefController.prefToru!.vehicle_driver_id,
      tour_start: _prefController.prefToru!.tour_start,
      tour_end: _prefController.prefToru!.tour_end,
      beaufort_wind: _prefController.prefToru!.beaufort_wind,
      date: _prefController.prefToru!.date,
      duration_from: tOD.getTimeOfDay(),
      duration_until: tOD.getTimeOfDay(),
      location_begin: location,
      location_end: location,
      distance_coast: "$distance",
      species_count: 1,
      other: otherName,
      note: "Short insert",
      syncStatus: Sighting.SYNC_STATUS_OPEN,
      sightingType: Sighting.TYPE_SHORT
    ));

    _loadController();
  }

  _updateTitle() {
    try {
      if (_prefController.prefToru != null) {
        if ((_prefController.prefToru!.use_home_area == null) || (_prefController.prefToru!.use_home_area! < 1)) {
          // without home area -------------------------------------------------

          DateTime tDate = DateTime.parse(_prefController.prefToru!.date!);

          if (!diffTourDateIgnored) {
            if (!UtilDate.isCurrentDate(tDate)) {
              Future.delayed(Duration.zero, () =>
                  ConfirmDialog.show(
                      context,
                      "Tour date",
                      "The tour date is not current, please check!",
                          (select) async {
                        if (select == "ok") {
                          await Get.toNamed('/setTour');
                          _sightingController.getSightings();
                        } else {
                          diffTourDateIgnored = true;
                        }
                      }
                  ));
            }
          }

          setState(() {
            statusTitle =
            "Tour: ${_prefController.prefToru!.date!} - ${_prefController
                .prefToru!.tour_start!}";
          });
        } else {
          // with Home area ----------------------------------------------------

          if (_locationController.homeAreaToru == null) {
            setState(() {
              statusTitle = "Tour: In Home-Area, wait for start";
            });
          } else {
            setState(() {
              statusTitle = "Tour: ${_locationController.homeAreaToru!
                  .date!} - ${_locationController.homeAreaToru!.tour_start!}";
            });
          }
        }
      }
    } catch(e) {
      if (kDebugMode) {
        print('ListPage::_addTaskBar: date parsing error:');
        print(e);
      }
    }
  }

  /// _addTaskBar
  _addTaskBar(BuildContext context) {
    List<Widget> columnList = [
      Text(
        statusTitle,
        style: subHeadingStyle,
      ),
      const SizedBox(height: 5),
    ];

    List<Widget> btnList = [];

    btnList.add(GetBuilder<PrefController>(builder: (prefController) {
      if (prefController.prefToru != null) {
        var setEndTour = false;
        var useHomeArea = false;

        if (prefController.prefToru!.set_end_tour != null && prefController.prefToru!.set_end_tour! >= 1) {
          setEndTour = true;
        }

        if (prefController.prefToru!.use_home_area != null && prefController.prefToru!.use_home_area! >= 1) {
          useHomeArea = true;
        }

        if (setEndTour && !useHomeArea) {
          return DefaultButton(
              buttonIcon: Icons.tour,
              label: 'Tour End',
              height: 40,
              width: 88,
              onTab: () async {
                _setEndTour(context);
              }
          );
        }

      }

      return Container();
    }));

    if (btnList.isNotEmpty) {
      btnList.add(const SizedBox(width: 5));
    }

    // TODO, fast button animals should come from the database in the future
    btnList.add(DefaultButton(
      buttonIcon: MaterialCommunityIcons.tortoise,
      label: 'Add Tortoise',
      height: 40,
      width: 120,
      bgColor: Colors.green,
      onTab: () async {
        showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius:BorderRadius.circular(30.0)
                ),
                child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Please select"),
                    const SizedBox(height: 15),
                    DefaultButton(
                        label: 'Caretta caretta\nLoggerhead sea turtle',
                        bgColor: Colors.green,
                        onTab: () {
                          Navigator.of(context).pop();
                          _addShortSighting('Caretta caretta - Loggerhead sea turtle', context);
                        }
                    ),
                    const SizedBox(width: 15),
                    DefaultButton(
                        label: 'Dermochelys coriacea\nLeatherback sea turtle',
                        bgColor: Colors.green,
                        onTab: () {
                          Navigator.of(context).pop();
                          _addShortSighting('Dermochelys coriacea - Leatherback sea turtle', context);
                        }
                    ),
                    const SizedBox(height: 15),
                    DefaultButton(
                        label: 'Chelonia mydas\nGreen sea turtle',
                        bgColor: Colors.green,
                        onTab: () {
                          Navigator.of(context).pop();
                          _addShortSighting('Chelonia mydas - Green sea turtle', context);
                        }
                    ),
                    const SizedBox(width: 15),
                    DefaultButton(
                        label: 'Eretmochelys imbricata\nHawksbill sea turtle',
                        bgColor: Colors.green,
                        onTab: () {
                          Navigator.of(context).pop();
                          _addShortSighting('Eretmochelys imbricata - Hawksbill sea turtle', context);
                        }
                    ),
                    const SizedBox(width: 15),
                    DefaultButton(
                        label: 'Unknown sea turtle',
                        bgColor: Colors.teal,
                        onTab: () {
                          Navigator.of(context).pop();
                          _addShortSighting('Unknown sea turtle', context);
                        }
                    ),
                    const SizedBox(height: 15),
                    DefaultButton(label: 'Cancel', onTab: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                )
                )
              );
            },
        );
      }
    ));

    columnList.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: btnList,
    ));

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnList,
          ),
        ],
      ),
    );
  }

  /// _addMapBar
  _addMapBar() {
    return Container(
        height: 200,
        decoration: const BoxDecoration(
            color: kButtonBackgroundColor
        ),
        child: const ListMap()
    );
  }

  /// _showSighting
  _showSighting() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: _sightingController.sightingList.length,
          itemBuilder: (_, index) {
            Sighting sighting = _sightingController.sightingList[index];

            return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(
                              context,
                              sighting
                            );
                          },
                          child: ListSightingTile(sighting),
                        )
                      ],
                    ),
                  ),
                )
            );
          }
        );
      })
    );
  }

  /// _bottomSheetButton
  _bottomSheetButton({
    required String label,
    required Function()? onTab,
    required Color clr,
    required BuildContext context
  }) {
    return GestureDetector(
      onTap: onTab,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey[600]!
          ),
          borderRadius: BorderRadius.circular(20),
          color: clr
        ),
        child: Center(
          child: Text(
            label,
            style: clr == Colors.white ?
              titleStyle.copyWith(color: kPrimaryFontColor) :
              titleStyle.copyWith(color: kPrimaryDarkFontColor),
          ),
        ),
      ),
    );
  }

  /// _showBottomSheet
  _showBottomSheet(BuildContext context, Sighting sighting) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: MediaQuery.of(context).size.height * 0.32,
        color: Get.isDarkMode ? kPrimaryDarkBackgroundColor : kPrimaryBackgroundColor,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[900] : Colors.grey[300]
              ),
            ),
            const Spacer(),
            _bottomSheetButton(
              label: 'Edit',
              onTab: () async {
                await Get.to(() => EditSightingPage(sighting: sighting));
                _sightingController.getSightings();
                Get.back();
              },
              clr: kPrimaryHeaderColor,
              context: context
            ),
            const SizedBox(height: 20),
            _bottomSheetButton(
                label: 'Delete',
                onTab: () async {
                  await _sightingController.delete(sighting);
                  _sightingController.getSightings();
                  Get.back();
                },
                clr: Colors.red[300]!,
                context: context
            ),
            const SizedBox(height: 20),
            _bottomSheetButton(
                label: 'Close',
                onTab: () {
                  Get.back();
                },
                clr: Colors.white,
                context: context
            ),
            const SizedBox(height: 10),
          ],
        ),
      )
    );
  }

  /// build
  @override
  Widget build(BuildContext context) {
    _loadController();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: _appBar(),
        body: Column(
          children: [
            _addTaskBar(context),
            const SizedBox(height: 20),
            _addMapBar(),
            const SizedBox(height: 20),
            _showSighting(),
          ],
        ),
      ),
    );
  }
}