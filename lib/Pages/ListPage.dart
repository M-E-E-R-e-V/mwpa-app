import 'dart:async';
import 'dart:convert';
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
import 'package:mwpaapp/Pages/IntroPage.dart';
import 'package:mwpaapp/Components/LanguageSelector.dart';
import 'package:mwpaapp/Pages/List/GpsStatusIndicator.dart';
import 'package:mwpaapp/Pages/List/LowBatteryBanner.dart';
import 'package:mwpaapp/Pages/List/SyncStatusLine.dart';
import 'package:mwpaapp/Pages/List/TourSummaryCard.dart';
import 'package:mwpaapp/Util/UtilTourSummary.dart';
import 'package:mwpaapp/Controllers/SyncController.dart';
import 'package:mwpaapp/Pages/List/ListSightingTile.dart';
import 'package:mwpaapp/Services/SyncMwpaService.dart';
import 'package:mwpaapp/Settings/CredentialStore.dart';
import 'package:mwpaapp/Util/UtilDate.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';
import 'package:mwpaapp/Util/UtilSighting.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:provider/provider.dart';
import 'List/ListMap.dart';
import 'package:mwpaapp/Ui/AppIcons.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:mwpaapp/l10n/l10n.dart';

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

  late final SyncController _sync = context.read<SyncController>();
  late final TabController _tabController;

  bool diffTourDateIgnored = false;
  /// shown tour: date and start of the default / home area tour, null
  /// when no tour date is set
  String? _tourDate;
  String? _tourStart;

  /// home area mode, tour not started yet
  bool _waitingInHomeArea = false;

  /// initState
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // creates the controller: the automatic sync starts with the main screen
    _sync;

    _locationController.updateEvent.addListener(_updateTitle);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadController();

      // first start: short introduction (skippable, again under Help)
      if (mounted && !context.read<PrefController>().introSeen) {
        IntroPage.show(context);
      }
    });
  }

  /// dispose
  @override
  void dispose() {
    _locationController.updateEvent.removeListener(_updateTitle);
    _tabController.dispose();

    super.dispose();
  }

  /// _syncMwpa - sync by hand; [dialog]: progress dialog (menu), otherwise
  /// the pull-to-refresh indicator shows it. Errors are shown in a dialog.
  Future<void> _syncMwpa({bool dialog = true}) async {
    SyncProgressDialog? progress;

    void onProgress() {
      final step = _sync.step;

      if (progress != null && mounted && step != null) {
        progress.update(_sync.percent, _syncStepLabel(context, step, _sync.detail));
      }
    }

    if (dialog) {
      progress = SyncProgressDialog()..show(context);
      _sync.addListener(onProgress);
    }

    final error = await _sync.syncNow();

    _sync.removeListener(onProgress);
    progress?.close();

    if (!mounted) return;

    if (error != null) {
      _showSyncError(error);
    }

    setState(() { });
  }

  /// _showSyncError - error of a sync in the UI language where known
  void _showSyncError(Object error) {
    final l10n = context.l10n;

    if (error is ApiVersionException) {
      final server = error.server;
      final accepted = error.accepted.join(', ');
      InfoDialog.show(
        context,
        l10n.error,
        error.sync ? l10n.apiSyncChanged(server, accepted) : l10n.apiLoginChanged(server, accepted),
        isError: true,
      );
    } else if (error is MwpaConnectionException) {
      InfoDialog.show(context, l10n.error, error.timeout ? l10n.serverTimeout : l10n.serverUnreachable, isError: true);
    } else if (error is LoginRejectedException) {
      InfoDialog.show(context, l10n.error, l10n.syncLoginRejected, isError: true);
    } else if (error is MissingCredentialsException) {
      InfoDialog.show(context, l10n.error, l10n.syncSignInAgain, isError: true);
    } else if (error is MwpaException) {
      InfoDialog.show(context, l10n.error, error.toString(), isError: true);
    } else {
      InfoDialog.show(context, l10n.internalError, error.toString(), isError: true);
    }
  }

  /// _syncStepLabel - progress text of a sync step in the UI language
  static String _syncStepLabel(BuildContext context, SyncStep step, String? detail) {
    final l10n = context.l10n;

    return switch (step) {
      SyncStep.vehicles => l10n.syncStepVehicles,
      SyncStep.species => l10n.syncStepSpecies,
      SyncStep.encounterCategories => l10n.syncStepEncounterCategories,
      SyncStep.behaviouralStates => l10n.syncStepBehaviouralStates,
      SyncStep.sightings => l10n.syncStepSightings,
      SyncStep.sightingImages => l10n.syncStepImages,
      SyncStep.tracking => l10n.syncStepTracking(detail ?? ''),
      SyncStep.finish => l10n.syncStepFinish,
    };
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
        ? context.l10n.logoutQuestion
        : context.l10n.logoutUnsynced(unsynced);

    ConfirmDialog.show(context, context.l10n.logout, message, destructive: unsynced > 0, okLabel: context.l10n.logout, (p0) async {
      if (p0 == "ok") {
        AppLog.i('List', 'logout ($unsynced unsynced sightings)');
        await CredentialStore().deletePassword();
        await _prefController.logout();
        _locationController.resetTour();
        _sync.reset();

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
      context.l10n.tourEnd,
      context.l10n.tourEndQuestion,
      (value) async {
        if (value == "ok") {
          if (_prefController.prefToru != null) {
            final tourFid = UtilTourFid.createTTourFId(_prefController.prefToru!);
            await UtilSighting.setCurrentEndTour(_sightingController, tourFid);
            await _loadController();

            if (!context.mounted) return;
            await TourSummaryDialog.show(context, _endedTourSummary(tourFid));
          } else {
            AppLog.w('List', 'setEndTour: no default tour set');
          }
        }
      }
    );
  }

  /// _endedTourSummary - summary of the tour just ended (also without
  /// sightings: duration and distance)
  TourSummary _endedTourSummary(String tourFid) {
    for (final tour in UtilTourSummary.group(_sightingController.sightingList)) {
      if (tour.tourFid == tourFid) {
        return tour;
      }
    }

    final pref = _prefController.prefToru;
    final now = TimeOfDay.now();

    return TourSummary(
      tourFid: tourFid,
      date: pref?.date,
      start: pref?.tour_start,
      end: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      sightings: const [],
    );
  }

  /// _appBar
  AppBar _appBar() {
    final dark = isDarkMode(context);

    // two buttons on each side, so the title is really centered
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/whale_tail.png',
            height: 26,
            color: kButtonFontColor,
            semanticLabel: 'MWPA',
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 10),
          const Text('MWPA'),
        ],
      ),
      leadingWidth: 104,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const LanguageSelector(),
          IconButton(
            tooltip: dark ? context.l10n.switchToLightTheme : context.l10n.switchToDarkTheme,
            onPressed: () {
              context.read<ThemeController>().switchTheme();
            },
            icon: Icon(
              dark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            ),
          ),
        ],
      ),
      actions: [
        const GpsStatusIcon(),
        PopupMenuButton<String>(
          tooltip: context.l10n.menu,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'settour',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.event_note_outlined),
                title: Text(context.l10n.setDefaultTour),
              ),
            ),
            PopupMenuItem(
              value: 'sync',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.sync),
                title: Text(context.l10n.syncWithServer),
              ),
            ),
            PopupMenuItem(
              value: 'help',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.help_outline),
                title: Text(context.l10n.help),
              ),
            ),
            PopupMenuItem(
              value: 'about',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text(context.l10n.about),
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout),
                title: Text(context.l10n.logout),
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
              case 'help':
                Navigator.of(context).pushNamed('/Help');
                break;
              case 'about':
                Navigator.of(context).pushNamed('/About');
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
          Tab(icon: const Icon(Icons.tour_outlined), text: context.l10n.tabTour),
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
            text: context.l10n.tabSightings,
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
          context.l10n.info,
          (_prefController.prefToru?.use_home_area ?? 0) >= 1
              ? context.l10n.tourNotStartedHomeArea
              : context.l10n.setDefaultTourFirst
      );

      return;
    }

    final Position? pos = _locationController.currentPosition;

    if (pos == null) {
      InfoDialog.show(context, context.l10n.info, context.l10n.waitForGps);
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
      SnackBar(content: Text(context.l10n.addedSnack(otherName))),
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
                      context.l10n.tourDateTitle,
                      context.l10n.tourDateNotCurrent,
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
            _waitingInHomeArea = false;
            _tourDate = _prefController.prefToru!.date!;
            _tourStart = _prefController.prefToru!.tour_start!;
          });
        } else {
          // with Home area ----------------------------------------------------

          if (_locationController.homeAreaToru == null) {
            setState(() {
              _waitingInHomeArea = true;
            });
          } else {
            setState(() {
              _waitingInHomeArea = false;
              _tourDate = _locationController.homeAreaToru!.date!;
              _tourStart = _locationController.homeAreaToru!.tour_start!;
            });
          }
        }
      }
    } catch(e) {
      AppLog.w('List', 'tour date parsing error', e);
    }
  }

  /// _statusCard
  Widget _statusCard(BuildContext context) {
    final theme = Theme.of(context);
    // floats on the map: slightly translucent, with shadow
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.93),
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                    context.l10n.currentTour,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.7),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _waitingInHomeArea
                        ? context.l10n.tourWaitingHomeArea
                        : _tourDate == null
                            ? context.l10n.tourDateNotSet
                            : context.l10n.tourLabel(_tourDate!, _tourStart ?? ''),
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

  /// _actionRow - the two quick actions side by side, equal width; "Tour
  /// End" (if enabled for the default tour) below them
  Widget _actionRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.add,
                title: context.l10n.addSighting,
                subtitle: context.l10n.addSightingHint,
                color: kButtonBackgroundColor,
                foreground: kButtonFontColor,
                onTap: () async {
                  await Navigator.of(context).pushNamed('/Edit');
                  _sightingController.getSightings();
                },
              ),
            ),
            const SizedBox(width: 12),
            // TODO, fast button animals should come from the database in the future
            Expanded(
              child: _ActionTile(
                icon: AppIcons.tortoise,
                title: context.l10n.addTortoise,
                subtitle: context.l10n.addTortoiseHint,
                color: Colors.green.shade600,
                foreground: Colors.white,
                onTap: () => _showTortoiseDialog(context),
              ),
            ),
          ],
        ),
        Consumer<PrefController>(builder: (_, prefController, __) {
          if (prefController.prefToru != null) {
            final setEndTour = (prefController.prefToru!.set_end_tour ?? 0) >= 1;
            final useHomeArea = (prefController.prefToru!.use_home_area ?? 0) >= 1;
            if (setEndTour && !useHomeArea) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _setEndTour(context),
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(context.l10n.tourEnd),
                ),
              );
            }
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  /// _showTortoiseDialog
  void _showTortoiseDialog(BuildContext context) {
    // payload is stored with the sighting: always English
    final l10n = context.l10n;
    final turtles = <_TurtleChoice>[
      _TurtleChoice('Caretta caretta', l10n.turtleLoggerhead,
          'Caretta caretta - Loggerhead sea turtle'),
      _TurtleChoice('Dermochelys coriacea', l10n.turtleLeatherback,
          'Dermochelys coriacea - Leatherback sea turtle'),
      _TurtleChoice('Chelonia mydas', l10n.turtleGreen,
          'Chelonia mydas - Green sea turtle'),
      _TurtleChoice('Eretmochelys imbricata', l10n.turtleHawksbill,
          'Eretmochelys imbricata - Hawksbill sea turtle'),
      _TurtleChoice(l10n.turtleUnknown, l10n.turtleSeaTurtle, 'Unknown sea turtle'),
    ];

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          icon: const Icon(AppIcons.tortoise,
              size: 32, color: Colors.green),
          title: Text(context.l10n.addTortoiseTitle),
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
              child: Text(context.l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  /// _tourTab — Tab 1: map over the whole tab, the tour card floats on top,
  /// the quick actions at the bottom.
  Widget _tourTab(BuildContext context) {
    return ListMap(
      top: _statusCard(context),
      bottom: _actionRow(context),
    );
  }

  /// _sightingsTab — Tab 2: sync status on top, the list of sightings.
  Widget _sightingsTab(BuildContext context) {
    return Column(
      children: [
        SyncStatusLine(
          onSync: _syncMwpa,
          onShowError: _showSyncError,
        ),
        Expanded(child: _sightingsList(context)),
      ],
    );
  }

  /// _sightingsList — the full list of sightings.
  Widget _sightingsList(BuildContext context) {
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
                  context.l10n.noSightingsYet,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.noSightingsHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final items = <Object>[
        for (final tour in UtilTourSummary.group(sightings)) ...[tour, ...tour.sightings],
      ];

      // pull down to sync with the server
      return RefreshIndicator(
        onRefresh: () => _syncMwpa(dialog: false),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index];
            final delay = Duration(milliseconds: 50 * index.clamp(0, 8));

            // tour head, followed by the tour's sightings
            if (item is TourSummary) {
              return _FadeSlideIn(
                delay: delay,
                child: TourSummaryCard(key: ValueKey(item.tourFid), summary: item),
              );
            }

            final sighting = item as Sighting;
            return _FadeSlideIn(
              delay: delay,
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
                title: Text(context.l10n.edit),
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
                  context.l10n.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ConfirmDialog.show(
                    context,
                    context.l10n.deleteSightingTitle,
                    context.l10n.deleteSightingQuestion,
                    (value) async {
                      if (value == 'ok') {
                        await _sightingController.delete(sighting);
                        _sightingController.getSightings();
                      }
                    },
                    destructive: true,
                    okLabel: context.l10n.delete,
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(context.l10n.close),
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
              const LowBatteryBanner(),
              // background sync: thin progress bar
              ListenableBuilder(
                listenable: _sync,
                builder: (_, __) => _sync.running
                    ? LinearProgressIndicator(
                        minHeight: 3,
                        value: _sync.percent <= 0 ? null : _sync.percent / 100,
                      )
                    : const SizedBox.shrink(),
              ),
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

/// _ActionTile - large quick action on the tour tab: icon in a circle,
/// title and a short hint, content centered
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: color,
      elevation: 4,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: foreground.withValues(alpha: 0.2),
                child: Icon(icon, color: foreground, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground.withValues(alpha: 0.85),
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
