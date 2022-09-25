import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Pages/EditSightingPage.dart';
import 'package:mwpaapp/Pages/List/ListSightingTile.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Services/ThemeService.dart';

import 'List/ListMap.dart';


class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final LocationController _locationController = Get.put(LocationController());
  final SightingController _sightingController = Get.put(SightingController());
  final VehicleController _vehicleController = Get.put(VehicleController());
  final VehicleDriverController _vehicleDriverController = Get.put(VehicleDriverController());
  final SpeciesController _speciesController = Get.put(SpeciesController());
  final EncounterCategoriesController _encounterCategoriesController = Get.put(EncounterCategoriesController());
  final BehaviouralStateController _behaviouralStateController = Get.put(BehaviouralStateController());

  _syncMwpa() async {

    SyncMwpaService service = SyncMwpaService();
    await service.sync((p0) async {});

    await _vehicleController.getVehicle();
    await _vehicleDriverController.getVehicleDriver();
    await _speciesController.getSpecies();
    await _encounterCategoriesController.getEncounterCategorie();
    await _behaviouralStateController.getBehaviouralStates();
  }

  _loadController() async {
    await _speciesController.getSpecies();
    await _vehicleController.getVehicle();
    await _vehicleDriverController.getVehicleDriver();
    await _encounterCategoriesController.getEncounterCategorie();
    await _behaviouralStateController.getBehaviouralStates();
    _sightingController.getSightings();
  }

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
        PopupMenuButton(itemBuilder: (context) {
          var list = <PopupMenuEntry<Object>>[];
          list.add(
            const PopupMenuItem(
                value: "settour",
                child: Text("Set Tour")
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
              break;
          }
        },
        )
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                "Tour",
                style: headingStyle,
              )
            ],
          ),
          DefaultButton(
            label: "+ Add Sighting",
            onTab: () async {
              await Get.toNamed('/Edit');
              _sightingController.getSightings();
            }
          )
        ],
      ),
    );
  }

  _addMapBar() {
    return Container(
        height: 200,
        decoration: const BoxDecoration(
            color: kButtonBackgroundColor
        ),
        child: ListMap()
    );
  }

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
            width: 2,
            color: Colors.grey[600]!
          ),
          borderRadius: BorderRadius.circular(20),
          color: clr
        ),
        child: Center(
          child: Text(
            label,
            style: clr == Colors.white ? titleStyle : titleStyle.copyWith(
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }

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
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]
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

  @override
  Widget build(BuildContext context) {
    _loadController();

    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          const SizedBox(height: 20),
          _addMapBar(),
          const SizedBox(height: 20),
          _showSighting(),
        ],
      ),
    );
  }
}