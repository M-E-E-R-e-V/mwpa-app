import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Pages/EditSightingPage.dart';
import 'package:mwpaapp/Pages/List/ListSightingTile.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Services/ThemeService.dart';


class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final SightingController _sightingController = Get.put(SightingController());
  final VehicleController _vehicleController = Get.put(VehicleController());
  final VehicleDriverController _vehicleDriverController = Get.put(VehicleDriverController());
  final SpeciesController _speciesController = Get.put(SpeciesController());

  _syncMwpa() async {
    SyncMwpaService service = SyncMwpaService();
    await service.sync();
    await _vehicleController.getVehicle();
    await _vehicleDriverController.getVehicleDriver();
    await _speciesController.getSpecies();
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
        onSelected: (value) {
          switch (value) {
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
              //await Navigator.pushNamed(context, '/Edit')
              await Get.to(() => const EditSightingPage());
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
        child: null
    );
  }

  _showSighting() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: _sightingController.sightingList.length,
          itemBuilder: (_, index) {
            return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {

                          },
                          child: ListSightingTile(_sightingController.sightingList[index]),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          const SizedBox(height: 20),
          // _addMapBar(),
          _showSighting(),
        ],
      ),
    );
  }
}