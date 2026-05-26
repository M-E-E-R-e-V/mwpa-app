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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'List/ListMap.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

/// ListPage
class ListPage extends StatefulWidget {

  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

/// _ListPageState
class _ListPageState extends State<ListPage>
    with SingleTickerProviderStateMixin {
  final PrefController _prefController = Get.find<PrefController>();
  final LocationController _locationController = Get.put(LocationController());
  final SightingController _sightingController = Get.put(SightingController());
  final VehicleController _vehicleController = Get.put(VehicleController());
  final VehicleDriverController _vehicleDriverController = Get.put(VehicleDriverController());
  final SpeciesController _speciesController = Get.put(SpeciesController());
  final EncounterCategoriesController _encounterCategoriesController = Get.put(EncounterCategoriesController());
  final BehaviouralStateController _behaviouralStateController = Get.put(BehaviouralStateController());

  late StreamSubscription subscription;
  late final TabController _tabController;

  bool diffTourDateIgnored = false;
  bool isSyncInProgress = false;
  String statusTitle = "Tour: default date is not set";

  /// initState
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    subscription = Connectivity().onConnectivityChanged.listen(
        _syncCheckConnectivity
    );
  }

  /// dispose
  @override
  void dispose() {
    _tabController.dispose();
    subscription.cancel();

    super.dispose();
  }

  /// _syncCheckConnectivity
  _syncCheckConnectivity(List<ConnectivityResult> results) async {
    final hasInternet = results.any((r) => r != ConnectivityResult.none);

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
      title: const Text('MWPA'),
      leading: IconButton(
        tooltip: Get.isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
        onPressed: () {
          setState(() {
            ThemeService().switchTheme();
          });
        },
        icon: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Menu',
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'settour',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.event_note_outlined),
                title: Text('Set default Tour'),
              ),
            ),
            PopupMenuItem(
              value: 'sync',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.sync),
                title: Text('Sync with Server'),
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ),
          ],
          icon: const Icon(Icons.account_circle_outlined),
          onSelected: (value) async {
            switch (value) {
              case 'settour':
                await Get.toNamed('/setTour');
                _sightingController.getSightings();
                break;
              case 'sync':
                _syncMwpa();
                break;
              case 'logout':
                _logout();
                break;
            }
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: kButtonBackgroundColor,
        indicatorWeight: 3,
        labelColor: kButtonFontColor,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(icon: Icon(Icons.tour_outlined), text: 'Tour'),
          Tab(icon: Icon(Icons.list_alt), text: 'Sightings'),
        ],
      ),
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

  /// _statusCard
  Widget _statusCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.tour_outlined,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current tour',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.7),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// _actionRow
  Widget _actionRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        GetBuilder<PrefController>(builder: (prefController) {
          if (prefController.prefToru != null) {
            final setEndTour = (prefController.prefToru!.set_end_tour ?? 0) >= 1;
            final useHomeArea = (prefController.prefToru!.use_home_area ?? 0) >= 1;
            if (setEndTour && !useHomeArea) {
              return FilledButton.tonalIcon(
                onPressed: () => _setEndTour(context),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Tour End'),
              );
            }
          }
          return const SizedBox.shrink();
        }),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: kButtonBackgroundColor,
            foregroundColor: kButtonFontColor,
          ),
          onPressed: () async {
            await Get.toNamed('/Edit');
            _sightingController.getSightings();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Sighting'),
        ),
        // TODO, fast button animals should come from the database in the future
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _showTortoiseDialog(context),
          icon: const Icon(MaterialCommunityIcons.tortoise),
          label: const Text('Add Tortoise'),
        ),
      ],
    );
  }

  /// _showTortoiseDialog
  void _showTortoiseDialog(BuildContext context) {
    const turtles = <_TurtleChoice>[
      _TurtleChoice('Caretta caretta', 'Loggerhead sea turtle',
          'Caretta caretta - Loggerhead sea turtle'),
      _TurtleChoice('Dermochelys coriacea', 'Leatherback sea turtle',
          'Dermochelys coriacea - Leatherback sea turtle'),
      _TurtleChoice('Chelonia mydas', 'Green sea turtle',
          'Chelonia mydas - Green sea turtle'),
      _TurtleChoice('Eretmochelys imbricata', 'Hawksbill sea turtle',
          'Eretmochelys imbricata - Hawksbill sea turtle'),
      _TurtleChoice('Unknown', 'Sea turtle', 'Unknown sea turtle'),
    ];

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          icon: const Icon(MaterialCommunityIcons.tortoise,
              size: 32, color: Colors.green),
          title: const Text('Add tortoise sighting'),
          contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: turtles.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final t = turtles[i];
                return ListTile(
                  leading: const Icon(MaterialCommunityIcons.tortoise,
                      color: Colors.green),
                  title: Text(t.scientific),
                  subtitle: Text(t.common),
                  onTap: () {
                    Navigator.of(dialogCtx).pop();
                    _addShortSighting(t.payload, context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// _tourTab — Tab 1: Status card, quick actions, map.
  Widget _tourTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statusCard(context),
          const SizedBox(height: 12),
          _actionRow(context),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: kButtonBackgroundColor,
                child: const ListMap(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// _sightingsTab — Tab 2: the full list of sightings.
  Widget _sightingsTab(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final sightings = _sightingController.sightingList;
      if (sightings.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.travel_explore_outlined,
                  size: 56,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No sightings yet',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap "Add Sighting" to record one.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        itemCount: sightings.length,
        itemBuilder: (_, index) {
          final sighting = sightings[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            child: SlideAnimation(
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () => _showBottomSheet(context, sighting),
                  child: ListSightingTile(sighting),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  /// _showBottomSheet
  _showBottomSheet(BuildContext context, Sighting sighting) {
    final theme = Theme.of(context);

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 48,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                title: const Text('Edit'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () async {
                  Get.back();
                  await Get.to(() => EditSightingPage(sighting: sighting));
                  _sightingController.getSightings();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () async {
                  Get.back();
                  await _sightingController.delete(sighting);
                  _sightingController.getSightings();
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
        body: TabBarView(
          controller: _tabController,
          children: [
            _tourTab(context),
            _sightingsTab(context),
          ],
        ),
      ),
    );
  }
}

class _TurtleChoice {
  final String scientific;
  final String common;
  final String payload;
  const _TurtleChoice(this.scientific, this.common, this.payload);
}