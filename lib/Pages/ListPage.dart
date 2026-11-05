import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Components/Inputs/DynInputValue.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/ThemeController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Dialog/ConfirmDialog.dart';
import 'package:mwpaapp/Dialog/InfoDialog.dart';
import 'package:mwpaapp/Dialog/SyncProgressDialog.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Mwpa/MwpaException.dart';
import 'package:mwpaapp/Pages/EditSightingPage.dart';
import 'package:mwpaapp/Pages/List/GpsStatusIndicator.dart';
import 'package:mwpaapp/Pages/List/ListSightingTile.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Settings/CredentialStore.dart';
import 'package:mwpaapp/Util/UtilDate.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'List/ListMap.dart';
import 'package:mwpaapp/Ui/AppIcons.dart';

/// ListPage
class ListPage extends StatefulWidget {

  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

/// _ListPageState
class _ListPageState extends State<ListPage>
    with SingleTickerProviderStateMixin {
  late final PrefController _prefController = context.read<PrefController>();
  late final LocationController _locationController = context.read<LocationController>();
  late final SightingController _sightingController = context.read<SightingController>();
  late final VehicleController _vehicleController = context.read<VehicleController>();
  late final VehicleDriverController _vehicleDriverController = context.read<VehicleDriverController>();
  late final SpeciesController _speciesController = context.read<SpeciesController>();
  late final EncounterCategoriesController _encounterCategoriesController = context.read<EncounterCategoriesController>();
  late final BehaviouralStateController _behaviouralStateController = context.read<BehaviouralStateController>();

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

    _locationController.updateEvent.addListener(_updateTitle);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadController());
  }

  /// dispose
  @override
  void dispose() {
    _locationController.updateEvent.removeListener(_updateTitle);
    _tabController.dispose();
    subscription.cancel();

    super.dispose();
  }

  /// _syncCheckConnectivity
  Future<void> _syncCheckConnectivity(List<ConnectivityResult> results) async {
    final hasInternet = results.any((r) => r != ConnectivityResult.none);

    if (hasInternet) {
      if (_sightingController.sightingList.isNotEmpty) {
        _syncMwpa();
      }
    }
  }

  /// _syncMwpa
  Future<void> _syncMwpa() async {
    if (isSyncInProgress) {
      return;
    }

    final progress = SyncProgressDialog()..show(context);
    SyncMwpaService service = SyncMwpaService(_speciesController);

    try {
      isSyncInProgress = true;

      await service.sync((p0, p1) async {
        progress.update(p0.round(), p1);
      });

      await _vehicleController.getVehicle();
      await _vehicleDriverController.getVehicleDriver();
      await _speciesController.getSpecies();
      await _encounterCategoriesController.getEncounterCategorie();
      await _behaviouralStateController.getBehaviouralStates();
      await _locationController.reloadSettings();
      await _sightingController.getSightings();

      isSyncInProgress = false;
      progress.close();
    } catch(error) {
      isSyncInProgress = false;
      progress.close();

      if (!mounted) return;

      if (error is MwpaException) {
        InfoDialog.show(context, 'Error', error.toString());
      } else {
        InfoDialog.show(context, 'Internal Error', error.toString());
      }
    }

    if (!mounted) return;
    setState(() { });
  }

  /// _loadController
  ///
  /// Reloads reference data, settings and sightings from the local DB; called
  /// once on start and after returning from pages that change them.
  Future<void> _loadController() async {
    await _speciesController.getSpecies();
    await _vehicleController.getVehicle();
    await _vehicleDriverController.getVehicleDriver();
    await _encounterCategoriesController.getEncounterCategorie();
    await _behaviouralStateController.getBehaviouralStates();
    await _locationController.reloadSettings();

    await _sightingController.getSightings();
    _updateTitle();
  }

  /// _logout
  Future<void> _logout() async {
    // sightings not on the server yet would otherwise be uploaded with the
    // next user's session
    final unsynced = _sightingController.sightingList
        .where((s) => s.unid == '' || s.syncStatus == Sighting.SYNC_STATUS_OPEN)
        .length;

    final message = unsynced == 0
        ? "Do you want to logout?"
        : "$unsynced sighting(s) are not synced yet. Please sync before you "
          "logout, otherwise they are uploaded with the next login.\n\n"
          "Logout anyway?";

    ConfirmDialog.show(context, "Logout", message, destructive: unsynced > 0, okLabel: 'Logout', (p0) async {
      if (p0 == "ok") {
        await CredentialStore().deletePassword();
        await _prefController.logout();
        _locationController.resetTour();

        if (!mounted) return;
        // the list of the old session must not stay underneath
        await Navigator.of(context).pushNamedAndRemoveUntil('/Login', (_) => false);
      }
    });
  }

  /// _setEndTour
  void _setEndTour(BuildContext context) {
    ConfirmDialog.show(
      context,
      "Tour End",
      "Update the tour end time for all sighting entries from the current tour?",
      (value) async {
        if (value == "ok") {
          if (_prefController.prefToru != null) {
            UtilSighting.setCurrentEndTour(_sightingController, UtilTourFid.createTTourFId(_prefController.prefToru!));
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
  AppBar _appBar() {
    final dark = isDarkMode(context);

    return AppBar(
      title: const Text('MWPA'),
      leading: IconButton(
        tooltip: dark ? 'Switch to light theme' : 'Switch to dark theme',
        onPressed: () {
          context.read<ThemeController>().switchTheme();
        },
        icon: Icon(
          dark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
        ),
      ),
      actions: [
        const GpsStatusIcon(),
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
                await Navigator.of(context).pushNamed('/setTour');
                _loadController();
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
        tabs: [
          const Tab(icon: Icon(Icons.tour_outlined), text: 'Tour'),
          Tab(
            icon: ListenableBuilder(
              listenable: _sightingController,
              builder: (_, __) {
                final count = _sightingController.sightingList.length;

                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: kButtonBackgroundColor,
                  child: const Icon(Icons.list_alt),
                );
              },
            ),
            text: 'Sightings',
          ),
        ],
      ),
    );
  }

  /// _addShortSighting
  Future<void> _addShortSighting(String otherName, BuildContext context) async {
    final tour = UtilSighting.shortSightingTour(
      prefTour: _prefController.prefToru,
      homeAreaTour: _locationController.homeAreaToru,
    );

    if (tour == null) {
      InfoDialog.show(
          context,
          "Info",
          (_prefController.prefToru?.use_home_area ?? 0) >= 1
              ? "The tour has not started yet (still in the home area). The entry cannot be added until then."
              : "Please set the default tour with date and start time beforehand. The entry cannot be added until then."
      );

      return;
    }

    final Position? pos = _locationController.currentPosition;

    if (pos == null) {
      InfoDialog.show(context, 'Info', "Please wait for the GPS signal.");
      return;
    }

    DynInputValue tOD = DynInputValue();
    tOD.timeValue = TimeOfDay.now();
    String location = jsonEncode(pos.toJson());
    var distance = UtilDistanceCoast.getDistance(pos);

    await _sightingController.addSighting(newSighting: Sighting(
      unid: '',
      tour_fid: UtilTourFid.createTTourFId(tour),
      vehicle_id: tour.vehicle_id!,
      vehicle_driver_id: tour.vehicle_driver_id,
      tour_start: tour.tour_start,
      tour_end: tour.tour_end,
      beaufort_wind: tour.beaufort_wind,
      date: tour.date,
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

    await _sightingController.getSightings();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added: $otherName')),
    );
  }

  void _updateTitle() {
    try {
      if (_prefController.prefToru != null) {
        if ((_prefController.prefToru!.use_home_area == null) || (_prefController.prefToru!.use_home_area! < 1)) {
          // without home area -------------------------------------------------

          DateTime tDate = DateTime.parse(_prefController.prefToru!.date!);

          if (!diffTourDateIgnored) {
            if (!UtilDate.isCurrentDate(tDate)) {
              Future.delayed(Duration.zero, () {
                  if (!mounted) return;
                  ConfirmDialog.show(
                      context,
                      "Tour date",
                      "The tour date is not current, please check!",
                          (select) async {
                        if (select == "ok") {
                          if (!mounted) return;
                          await Navigator.of(context).pushNamed('/setTour');
                          _loadController();
                        } else {
                          diffTourDateIgnored = true;
                        }
                      }
                  );
              });
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
              backgroundColor: kButtonBackgroundColor,
              child: const Icon(
                Icons.tour_outlined,
                color: kButtonFontColor,
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
        Consumer<PrefController>(builder: (_, prefController, __) {
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
            await Navigator.of(context).pushNamed('/Edit');
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
          icon: const Icon(AppIcons.tortoise),
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
          icon: const Icon(AppIcons.tortoise,
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
                  leading: const Icon(AppIcons.tortoise,
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
    return ListenableBuilder(
      listenable: _sightingController,
      builder: (_, __) {
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

      // pull down to sync with the server
      return RefreshIndicator(
        onRefresh: _syncMwpa,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
          itemCount: sightings.length,
          itemBuilder: (_, index) {
            final sighting = sightings[index];
            return _FadeSlideIn(
              delay: Duration(milliseconds: 50 * index.clamp(0, 8)),
              child: ListSightingTile(
                sighting,
                onTap: () => _showBottomSheet(context, sighting),
              ),
            );
          },
        ),
      );
    });
  }

  /// _showBottomSheet
  void _showBottomSheet(BuildContext context, Sighting sighting) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '${sighting.date ?? ''} · ${sighting.duration_from ?? ''}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                title: const Text('Edit'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EditSightingPage(sighting: sighting),
                  ));
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
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ConfirmDialog.show(
                    context,
                    'Delete sighting',
                    'Delete this sighting from the device? Already synced data stays on the server.',
                    (value) async {
                      if (value == 'ok') {
                        await _sightingController.delete(sighting);
                        _sightingController.getSightings();
                      }
                    },
                    destructive: true,
                    okLabel: 'Delete',
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: _appBar(),
        // edge-to-edge (Android 15+): keep content clear of the gesture bar
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              const GpsOffBanner(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _tourTab(context),
                    _sightingsTab(context),
                  ],
                ),
              ),
            ],
          ),
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

/// _FadeSlideIn - fades and slides a list entry in once when it first appears
/// (replaces flutter_staggered_animations); [delay] staggers the entries.
class _FadeSlideIn extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _FadeSlideIn({required this.delay, required this.child});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 375),
  );

  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
