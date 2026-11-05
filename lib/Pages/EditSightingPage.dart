import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Components/Inputs/Inputs.dart';
import 'package:mwpaapp/Controllers/BeaufortController.dart';
import 'package:mwpaapp/Controllers/BehaviouralStateController.dart';
import 'package:mwpaapp/Controllers/EncounterCategoriesController.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/PrefController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Controllers/VehicleController.dart';
import 'package:mwpaapp/Controllers/VehicleDriverController.dart';
import 'package:mwpaapp/Dialog/ConfirmDialog.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Pages/EditSighting/MissingFields.dart';
import 'package:mwpaapp/Models/TourPref.dart';
import 'package:mwpaapp/Settings/Preference.dart';
import 'package:mwpaapp/Util/UtilDistanceCoast.dart';
import 'package:mwpaapp/Util/UtilImage.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:mwpaapp/l10n/l10n.dart';

/// EditSightingPage
class EditSightingPage extends StatefulWidget {
  final Sighting? sighting;

  const EditSightingPage({super.key, this.sighting});

  @override
  State<EditSightingPage> createState() => _EditSightingPageState();
}

/// _EditSightingPageState
class _EditSightingPageState extends State<EditSightingPage> {
  late final PrefController _prefController = context.read<PrefController>();
  late final LocationController _locationController = context.read<LocationController>();
  late final SightingController _sightingController = context.read<SightingController>();
  late final VehicleController _vehicleController = context.read<VehicleController>();
  late final VehicleDriverController _vehicleDriverController = context.read<VehicleDriverController>();
  late final SpeciesController _speciesController = context.read<SpeciesController>();
  late final EncounterCategoriesController _encounterCategoriesController = context.read<EncounterCategoriesController>();
  late final BehaviouralStateController _behaviouralStateController = context.read<BehaviouralStateController>();

  bool isInit = false;


  late Widget sightVehicle;
  DynInputValue sightVehicleValue = DynInputValue();

  late Widget sightVehicleDriver;
  DynInputValue sightVehicleDriverValue = DynInputValue();

  late Widget sightBeaufort;
  DynInputValue sightBeaufortValue = DynInputValue();

  late Widget sightDate;
  DynInputValue sightDateValue = DynInputValue();

  late Widget sightTourStart;
  DynInputValue sightTourStartValue = DynInputValue();

  late Widget sightTourEnd;
  DynInputValue sightTourEndValue = DynInputValue();

  late Widget sightDurationFrom;
  DynInputValue sightDurationFromValue = DynInputValue();

  late Widget sightDurationUntil;
  DynInputValue sightDurationUntilValue = DynInputValue();

  late Widget sightLocationBegin;
  DynInputValue sightLocationBeginValue = DynInputValue();

  late Widget sightLocationEnd;
  DynInputValue sightLocationEndValue = DynInputValue();

  late Widget sightPhotoTaken;
  DynInputValue sightPhotoTakenValue = DynInputValue();

  late Widget sightDistanceCoast;
  DynInputValue sightDistanceCoastValue = DynInputValue();

  late Widget sightDistanceCoastEstimationGps;
  DynInputValue sightDistanceCoastEstimationGpsValue = DynInputValue();

  late Widget sightSpecies;
  DynInputValue sightSpeciesValue = DynInputValue();

  late Widget sightSpeciesNum;
  DynInputValue sightSpeciesNumValue = DynInputValue();

  late Widget sightJuveniles;
  DynInputValue sightJuvenilesValue = DynInputValue();

  late Widget sightCalves;
  DynInputValue sightCalvesValue = DynInputValue();

  late Widget sightNewborns;
  DynInputValue sightNewbornsValue = DynInputValue();

  late Widget sightBehaviour;
  DynInputValue sightBehaviourValue = DynInputValue();

  late Widget sightSubgroups;
  DynInputValue sightSubgroupsValue = DynInputValue();

  late Widget sightGroupStructure;
  DynInputValue sightGroupStructureValue = DynInputValue();

  late Widget sightReaction;
  DynInputValue sightReactionValue = DynInputValue();

  late Widget sightFreqBehaviour;
  DynInputValue sightFreqBehaviourValue = DynInputValue();

  late Widget sightRecAnimals;
  DynInputValue sightRecAnimalsValue = DynInputValue();

  late Widget sightOtherSpecies;
  DynInputValue sightOtherSpeciesValue = DynInputValue();

  late Widget sightOther;
  DynInputValue sightOtherValue = DynInputValue();

  late Widget sightOtherVehicle;
  DynInputValue sightOtherVehicleValue = DynInputValue();

  late Widget sightNote;
  DynInputValue sightNoteValue = DynInputValue();

  late Widget sightImage;
  DynInputValue sightImageValue = DynInputValue();

  /// _confirmClose - asks before leaving the page without saving; used by
  /// the app bar back button and the system back gesture/button
  void _confirmClose() {
    ConfirmDialog.show(
      context,
      context.l10n.sightingCloseTitle,
      context.l10n.sightingCloseQuestion,
      (value) {
        if (value == 'ok' && mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  /// _appBar
  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(widget.sighting == null ? context.l10n.addSightingTitle : context.l10n.editSightingTitle),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _confirmClose,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: DefaultButton(
            buttonIcon: Icons.save_alt,
            height: 40,
            label: context.l10n.save,
            onTab: _saveSightingToDb,
          ),
        ),
      ],
    );
  }

  /// _formSighting - the sighting as currently entered in the form (image
  /// path not yet persisted)
  Sighting _formSighting({String unid = ''}) {
    return Sighting(
      unid: unid,
      vehicle_id: sightVehicleValue.getStrValueAsInt(),
      vehicle_driver_id: sightVehicleDriverValue.getStrValueAsInt(),
      beaufort_wind: sightBeaufortValue.getValue(),
      date: sightDateValue.getDateTime(),
      tour_start: sightTourStartValue.getTimeOfDay(),
      tour_end: sightTourEndValue.getTimeOfDay(),
      duration_from: sightDurationFromValue.getTimeOfDay(),
      duration_until: sightDurationUntilValue.getTimeOfDay(),
      location_begin: sightLocationBeginValue.getPosition(),
      location_end: sightLocationEndValue.getPosition(),
      photo_taken: sightPhotoTakenValue.getIntValue(),
      distance_coast: sightDistanceCoastValue.getValue(),
      distance_coast_estimation_gps: sightDistanceCoastEstimationGpsValue
          .getIntValue(),
      species_id: sightSpeciesValue.getStrValueAsInt(),
      species_count: sightSpeciesNumValue.getStrValueAsInt(),
      juveniles: sightJuvenilesValue.getIntValue(),
      calves: sightCalvesValue.getIntValue(),
      newborns: sightNewbornsValue.getIntValue(),
      behaviours: sightBehaviourValue.getMultiValue(),
      subgroups: sightSubgroupsValue.getIntValue(),
      group_structure_id: sightGroupStructureValue.getStrValueAsInt(),
      reaction_id: sightReactionValue.getStrValueAsInt(),
      freq_behaviour: sightFreqBehaviourValue.getValue(),
      recognizable_animals: sightRecAnimalsValue.getValue(),
      other_species: sightOtherSpeciesValue.getMultiValue(),
      other: sightOtherValue.getValue(),
      other_vehicle: sightOtherVehicleValue.getValue(),
      note: sightNoteValue.getValue(),
      image: sightImageValue.getImagePath(),
      syncStatus: Sighting.SYNC_STATUS_OPEN
    );
  }

  /// one key per required field, to scroll to it from the summary
  final Map<SightingField, GlobalKey> _fieldKeys = {
    for (final field in SightingField.values) field: GlobalKey(),
  };

  void _scrollTo(SightingField field) {
    final target = _fieldKeys[field]?.currentContext;

    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 300),
        alignment: 0.2,
      );
    }
  }

  /// _mark - input of a required field with the "missing" hint
  Widget _mark(SightingField field, List<SightingField> missing, Widget input) {
    return MissingFieldMark(
      key: _fieldKeys[field],
      field: field,
      missing: missing.contains(field),
      child: input,
    );
  }

  /// _saveSightingToDb - saves also when required fields are missing
  Future<void> _saveSightingToDb() async {
    var mUnid = "";

    if (widget.sighting != null) {
      mUnid = widget.sighting?.unid ?? "";
    }

    var pref = Preference();
    await pref.load();

    Sighting tSigh = _formSighting(unid: mUnid)
      ..creater_id = pref.getUserId()
      // older sightings may still point into the cache directory
      ..image = await UtilImage.persist(sightImageValue.getImagePath());

    tSigh.tour_fid = UtilTourFid.createSTourFId(tSigh);

    if (widget.sighting != null) {
      tSigh.id = widget.sighting?.id!;

      await _sightingController.updateSighting(tSighting: tSigh);
      AppLog.i('EditSighting', 'updated sighting ${tSigh.id}');
    } else {
      await _sightingController.addSighting(newSighting: tSigh);
      AppLog.i('EditSighting', 'added sighting');
    }

    if (!mounted) return;

    // saved anyway - remind which fields are still open
    final missing = tSigh.missingFields();

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.savedStillEmpty(missing.map((f) => f.localizedLabel(context)).join(', '))),
      ));
    }

    Navigator.of(context).pop();
  }

  /// _loadPref
  Future<void> _loadPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        if (prefs.containsKey(Preference.TOUR)) {
          TourPref tour = TourPref.fromJson(
              jsonDecode(prefs.getString(Preference.TOUR)!));

          //  vehicle
          if (_vehicleController.vehicleList.map(
                  (element) => element.id).contains(tour.vehicle_id!)
          ) {
            sightVehicleValue.setStrValueByInt(tour.vehicle_id!);
          }

          // vehicle driver
          if (_vehicleDriverController.vehicleDriverList.map(
                  (element) => element.id).contains(tour.vehicle_driver_id!)
          ) {
            sightVehicleDriverValue.setStrValueByInt(tour.vehicle_driver_id!);
          }

          sightBeaufortValue.setValue(tour.beaufort_wind!);
          sightDateValue.setDateTime(tour.date!);
          sightTourStartValue.setTimeOfDy(tour.tour_start!);
          sightTourEndValue.setTimeOfDy(tour.tour_end!);
        }
      });
    } catch(e) {
      AppLog.w('EditSighting', 'loading the tour defaults failed', e);
    }
  }

  /// _setLocationByTime
  Future<void> _setLocationByTime(BuildContext context, TimeOfDay aTimeOfDay, Function onSet) async {
    if (widget.sighting == null) {
      return;
    }

    if (_prefController.prefToru != null) {
      DateTime tDate = DateTime(
          sightDateValue.dateValue.year,
          sightDateValue.dateValue.month,
          sightDateValue.dateValue.day,
          aTimeOfDay.hour,
          aTimeOfDay.minute
      );

      final watch = Stopwatch()..start();

      Position? aPos = await _locationController.getLocationBy(
          UtilTourFid.createTTourFId(_prefController.prefToru!),
          tDate
      );

      // field report: the confirm dialog sometimes came late / the position
      // was not taken - log the lookup time and the user's answer
      AppLog.i('EditSighting',
          'position lookup for ${aTimeOfDay.hour}:${aTimeOfDay.minute.toString().padLeft(2, '0')}: '
          '${aPos == null ? 'none' : 'found'} in ${watch.elapsedMilliseconds} ms');

      if (aPos != null && context.mounted) {
        ConfirmDialog.show(
          context,
          context.l10n.positionFoundTitle, context.l10n.positionFoundQuestion,
              (p0) {
            AppLog.i('EditSighting', 'position by time: ${p0 ?? 'dismissed'}');

            if (p0 == "ok") {
              onSet(aPos);
            }
          });
      }
    }
  }

  /// _pair - two inputs side by side
  Widget _pair(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  /// initState
  @override
  void initState() {
    super.initState();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      isInit = true;
      Sighting? sighting = widget.sighting;


      if (sighting != null) {
        sightVehicleValue.setStrValueByInt(sighting.vehicle_id!);
        sightVehicleDriverValue.setStrValueByInt(sighting.vehicle_driver_id!);
        sightBeaufortValue.setValue(sighting.beaufort_wind!);
        sightDateValue.setDateTime(sighting.date!);
        sightTourStartValue.setTimeOfDy(sighting.tour_start!);
        sightTourEndValue.setTimeOfDy(sighting.tour_end!);
        sightDurationFromValue.setTimeOfDy(sighting.duration_from!);
        sightDurationUntilValue.setTimeOfDy(sighting.duration_until!);
        sightLocationBeginValue.setPositionStr(sighting.location_begin!);
        sightLocationEndValue.setPositionStr(sighting.location_end!);
        sightPhotoTakenValue.setIntValue(sighting.photo_taken!);
        sightDistanceCoastValue.setValue(sighting.distance_coast!);
        sightDistanceCoastEstimationGpsValue.setIntValue(
            sighting.distance_coast_estimation_gps!);
        sightSpeciesValue.setStrValueByInt(sighting.species_id!);
        sightSpeciesNumValue.setStrValueByInt(sighting.species_count!);
        sightJuvenilesValue.setIntValue(sighting.juveniles!);
        sightCalvesValue.setIntValue(sighting.calves!);
        sightNewbornsValue.setIntValue(sighting.newborns!);
        sightBehaviourValue.setMultiValue(sighting.behaviours!);
        sightSubgroupsValue.setIntValue(sighting.subgroups!);
        sightGroupStructureValue.setStrValueByInt(sighting.group_structure_id!);
        sightReactionValue.setStrValueByInt(sighting.reaction_id!);
        sightFreqBehaviourValue.setValue(sighting.freq_behaviour!);
        sightRecAnimalsValue.setValue(sighting.recognizable_animals!);
        sightOtherSpeciesValue.setMultiValue(sighting.other_species!);
        sightOtherValue.setValue(sighting.other!);
        sightOtherVehicleValue.setValue(sighting.other_vehicle!);
        sightNoteValue.setValue(sighting.note!);
        sightImageValue.setImagePath(sighting.image!);
      } else {
        _loadPref();

        // vehicle -------------------------------------------------------------
        // set as default when list have only one element
        if (_vehicleController.vehicleList.length == 1) {
          sightVehicleValue.setStrValueByInt(_vehicleController.vehicleList[0].id!);
        }

        // vehicle driver ------------------------------------------------------
        // set as default when list have only one element
        if (_vehicleDriverController.vehicleDriverList.length == 1) {
          sightVehicleDriverValue.setStrValueByInt(_vehicleDriverController.vehicleDriverList[0].id!);
        }

        sightDurationFromValue.setTimeof(TimeOfDay.now());
        sightJuvenilesValue.setIntValue(-1);
        sightCalvesValue.setIntValue(-1);
        sightNewbornsValue.setIntValue(-1);
        sightSubgroupsValue.setIntValue(-1);

        if (_locationController.currentPosition != null) {
          sightLocationBeginValue.setPosition(
              _locationController.currentPosition!);

          var distance = UtilDistanceCoast.getDistance(
              _locationController.currentPosition!);
          sightDistanceCoastValue.setValue("$distance");
        }
      }
    }

    return ListenableBuilder(
      listenable: Listenable.merge([
        _vehicleController,
        _vehicleDriverController,
        _speciesController,
        _encounterCategoriesController,
        _behaviouralStateController,
      ]),
      builder: (_, __) {
        final missing = _formSighting().missingFields();
        void refresh() => setState(() {});

        sightVehicle = SelectInput(
          title: context.l10n.labelBoat,
          value: sightVehicleValue,
          items: _vehicleController.vehicleList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.name!
             );
           }).toList(),
        );

         sightVehicleDriver = SelectInput(
           title: context.l10n.labelSkipper,
           value: sightVehicleDriverValue,
           items: _vehicleDriverController.vehicleDriverList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.username!
             );
           }).toList(),
         );

        sightBeaufort = SelectInput(
          title: context.l10n.labelBeaufort,
          value: sightBeaufortValue,
          items: BeaufortController.selectList(context.l10n.notSelected),
          searchable: false,
        );

        sightDate = DateInput(
          title: context.l10n.fieldDate,
          value: sightDateValue,
        );

         sightTourStart = _mark(SightingField.tourStart, missing, TimeInput(
           title: context.l10n.fieldTourStart,
           value: sightTourStartValue,
           onChange: refresh,
         ));

         sightTourEnd = _mark(SightingField.tourEnd, missing, TimeInput(
           title: context.l10n.fieldTourEnd,
           value: sightTourEndValue,
           onChange: refresh,
         ));

         sightDurationFrom = _mark(SightingField.beginTime, missing, TimeInput(
           title: context.l10n.labelSightingFrom,
           value: sightDurationFromValue,
           onChange: () {
             refresh();

             if (sightLocationBeginValue.posValue == null) {
               final current = _locationController.currentPosition;

               if (current != null) {
                 setState(() {
                   sightLocationBeginValue.posValue = current;
                   sightDistanceCoastValue.setValue("${UtilDistanceCoast.getDistance(current)}");
                 });
               }
             } else {
               _setLocationByTime(
                   context,
                   sightDurationFromValue.timeValue!,
                       (Position aPos) {
                     setState(() {
                       sightLocationBeginValue.setPosition(aPos);
                     });
                   }
               );
             }
           },
         ));

         sightDurationUntil = TimeInput(
           title: context.l10n.labelUntil,
           value: sightDurationUntilValue,
           onChange: () async {
             _setLocationByTime(
                 context,
                 sightDurationUntilValue.timeValue!,
                 (Position aPos) {
                   setState(() {
                     sightLocationEndValue.setPosition(aPos);
                   });
                 }
               );
           },
         );

         sightLocationBegin = _mark(SightingField.beginPosition, missing, LocationInput(
           title: context.l10n.fieldBeginPosition,
           value: sightLocationBeginValue,
           onChange: () {
             if (sightLocationBeginValue.posValue != null) {
               var distance = UtilDistanceCoast.getDistance(sightLocationBeginValue.posValue!);
               // rebuild, so the distance field shows the new value
               setState(() => sightDistanceCoastValue.setValue("$distance"));
             }
           },
         ));

         sightLocationEnd = _mark(SightingField.endPosition, missing, LocationInput(
           title: context.l10n.fieldEndPosition,
           value: sightLocationEndValue,
           onChange: refresh,
         ));

         sightPhotoTaken = SwitchInput(
           title: context.l10n.labelPhotosTaken,
           value: sightPhotoTakenValue,
         );

         sightDistanceCoast = DistanceInput(
           title: context.l10n.labelDistanceCoast,
           value: sightDistanceCoastValue,
         );

         sightDistanceCoastEstimationGps = SwitchInput(
           title: context.l10n.labelEstimationNoGps,
           value: sightDistanceCoastEstimationGpsValue,
         );

         sightSpecies = SelectInput(
           title: context.l10n.labelSpecies,
           value: sightSpeciesValue,
           items: _speciesController.speciesList.map((element) {
             var labelName = element.name!;

             if (element.name!.indexOf(',') > 0) {
               labelName = element.name!.split(",")[0];
             }

             return DynInputSelectItem(
                 value: element.orgid!.toString(),
                 label: labelName
             );
           }).toList(),
         );

         sightSpeciesNum = _mark(SightingField.count, missing, TextValueInput(
           title: context.l10n.fieldCount,
           value: sightSpeciesNumValue,
           kind: TextValueKind.digits,
           onChange: refresh,
         ));

         sightJuveniles = YesNoUnknownInput(
           title: context.l10n.labelJuveniles,
           value: sightJuvenilesValue,
         );

         sightCalves = YesNoUnknownInput(
           title: context.l10n.labelCalves,
           value: sightCalvesValue,
         );

         sightNewborns = YesNoUnknownInput(
           title: context.l10n.labelNewborns,
           value: sightNewbornsValue,
         );

         sightBehaviour = MultiSelectInput(
           title: context.l10n.labelBehaviour,
           value: sightBehaviourValue,
           items: _behaviouralStateController.behaviouralStateList.map((element) {
             return DynInputSelectItem(
                 value: element.id!.toString(),
                 label: element.name!
             );
           }).toList(),
         );

         sightSubgroups = YesNoUnknownInput(
           title: context.l10n.labelSubgroups,
           value: sightSubgroupsValue,
         );

        sightGroupStructure = SelectInput(
          title: context.l10n.labelGroupStructure,
          value: sightGroupStructureValue,
          items: [
            DynInputSelectItem(value: "1", label: context.l10n.groupWidelyDispersed),
            DynInputSelectItem(value: "2", label: context.l10n.groupDispersed),
            DynInputSelectItem(value: "3", label: context.l10n.groupLoose),
            DynInputSelectItem(value: "4", label: context.l10n.groupTight),
          ],
        );

         sightReaction = SelectInput(
           title: context.l10n.labelReaction,
           value: sightReactionValue,
           items: _encounterCategoriesController.encounterCategorieList.map((element) {
            return DynInputSelectItem(
              value: element.id!.toString(),
              label: element.name!
            );
          }).toList(),
         );

        sightFreqBehaviour = TagInput(
          title: context.l10n.labelFreqBehaviour,
          value: sightFreqBehaviourValue,
          suggestions: const ['Test', 'SLP', 'SPY'],
        );

        sightRecAnimals = TextValueInput(
          title: context.l10n.labelRecAnimals,
          value: sightRecAnimalsValue,
          kind: TextValueKind.textarea,
        );

        sightOtherSpecies = MultiSelectInput(
          title: context.l10n.labelOtherSpecies,
          value: sightOtherSpeciesValue,
          items: _speciesController.speciesList.map((element) {
            var labelName = element.name!;

            if (element.name!.indexOf(',') > 0) {
              labelName = element.name!.split(",")[0];
            }

            return DynInputSelectItem(
                value: element.id!.toString(),
                label: labelName
            );
          }).toList(),
        );

        sightOther = TextValueInput(
          title: context.l10n.labelOther,
          value: sightOtherValue,
          kind: TextValueKind.textarea,
          // a tortoise name here makes the count optional
          onChange: refresh,
        );

        sightOtherVehicle = TextValueInput(
          title: context.l10n.labelOtherBoats,
          value: sightOtherVehicleValue,
          kind: TextValueKind.textarea,
        );

        sightNote = TextValueInput(
          title: context.l10n.labelNote,
          value: sightNoteValue,
          kind: TextValueKind.textarea,
        );

        sightImage = ImageInput(
          value: sightImageValue,
        );

         return PopScope(
           canPop: false,
           // system back (button or gesture) asks like the app bar arrow
           onPopInvokedWithResult: (didPop, _) {
             if (!didPop) {
               _confirmClose();
             }
           },
           child: Scaffold(
             appBar: _appBar(context),
             body: SafeArea(
               top: false,
               child: SingleChildScrollView(
                 padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     MissingFieldsSummary(missing: missing, onTap: _scrollTo),
                     InputSection(
                       title: context.l10n.sectionTour,
                       icon: Icons.directions_boat_outlined,
                       children: [
                         sightVehicle,
                         sightVehicleDriver,
                         sightBeaufort,
                         sightDate,
                         _pair(sightTourStart, sightTourEnd),
                       ],
                     ),
                     InputSection(
                       title: context.l10n.sectionTimePosition,
                       icon: Icons.place_outlined,
                       children: [
                         _pair(sightDurationFrom, sightDurationUntil),
                         sightLocationBegin,
                         sightLocationEnd,
                         sightDistanceCoast,
                         sightDistanceCoastEstimationGps,
                         sightPhotoTaken,
                       ],
                     ),
                     InputSection(
                       title: context.l10n.sectionAnimals,
                       icon: Icons.pets_outlined,
                       children: [
                         sightSpecies,
                         sightSpeciesNum,
                         sightJuveniles,
                         sightCalves,
                         sightNewborns,
                         sightSubgroups,
                         sightGroupStructure,
                       ],
                     ),
                     InputSection(
                       title: context.l10n.sectionBehaviour,
                       icon: Icons.waves_outlined,
                       children: [
                         sightBehaviour,
                         sightReaction,
                         sightFreqBehaviour,
                         sightRecAnimals,
                       ],
                     ),
                     InputSection(
                       title: context.l10n.sectionNotes,
                       icon: Icons.notes_outlined,
                       children: [
                         sightOtherSpecies,
                         sightOther,
                         sightOtherVehicle,
                         sightNote,
                       ],
                     ),
                     InputSection(
                       title: context.l10n.sectionPicture,
                       icon: Icons.photo_camera_outlined,
                       children: [sightImage],
                     ),
                     const SizedBox(height: 8),
                     FilledButton.icon(
                       onPressed: _saveSightingToDb,
                       icon: const Icon(Icons.save_alt),
                       label: Text(context.l10n.saveSighting),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         );
     });
  }
}
