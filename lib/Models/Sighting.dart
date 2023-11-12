import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Util/UtilCheckJson.dart';
import 'package:mwpaapp/Util/UtilTourFId.dart';

import '../Controllers/SpeciesController.dart';

/// Sighting
class Sighting {

  static const int SYNC_STATUS_OPEN = 0;
  static const int SYNC_STATUS_FINISH = 1;

  static const int TYPE_NORMAL = 0;   // normal sighting
  static const int TYPE_SHORT = 1;    // over the fast button sample a turtle
  static const int TYPE_NOTICE = 2;   // only a notice
  static const int TYPE_FREE = 3;     // a free sighting without a tour

  int? id;
  String? unid;
  int? creater_id;
  int? vehicle_id;
  int? vehicle_driver_id;
  String? beaufort_wind;
  String? date;
  String? tour_fid;
  String? tour_start;
  String? tour_end;
  String? duration_from;
  String? duration_until;
  String? location_begin;
  String? location_end;
  int? photo_taken;
  String? distance_coast; // as float
  int? distance_coast_estimation_gps;
  int? species_id;
  int? species_count;
  int? juveniles;
  int? calves;
  int? newborns;
  String? behaviours;
  int? subgroups;
  int? group_structure_id;
  int? reaction_id;
  String? freq_behaviour;
  String? recognizable_animals;
  String? other_species;
  String? other;
  String? other_vehicle;
  String? note;
  String? image;
  int? syncStatus;
  int? sightingType;

  Sighting({
    this.id,
    required this.unid,
    this.creater_id,
    this.vehicle_id,
    this.vehicle_driver_id,
    this.date,
    this.beaufort_wind,
    this.tour_fid,
    this.tour_start,
    this.tour_end,
    this.duration_from,
    this.duration_until,
    this.location_begin,
    this.location_end,
    this.photo_taken,
    this.distance_coast,
    this.distance_coast_estimation_gps,
    this.species_id,
    this.species_count,
    this.juveniles,
    this.calves,
    this.newborns,
    this.behaviours,
    this.subgroups,
    this.group_structure_id,
    this.reaction_id,
    this.freq_behaviour,
    this.recognizable_animals,
    this.other_species,
    this.other,
    this.other_vehicle,
    this.note,
    this.image,
    this.syncStatus,
    this.sightingType
  });

  /// fromJson
  Sighting.fromJson(Map<String, dynamic> json) {
    id = UtilCheckJson.checkValue(json['id'], UtilCheckJsonTypes.int);
    unid = UtilCheckJson.checkValue(json['unid'], UtilCheckJsonTypes.string);
    creater_id = UtilCheckJson.checkValue(json['creater_id'], UtilCheckJsonTypes.int);
    vehicle_id = UtilCheckJson.checkValue(json['vehicle_id'], UtilCheckJsonTypes.int);
    vehicle_driver_id = UtilCheckJson.checkValue(json['vehicle_driver_id'], UtilCheckJsonTypes.int);
    beaufort_wind = UtilCheckJson.checkValue(json['beaufort_wind'], UtilCheckJsonTypes.string);
    date = UtilCheckJson.checkValue(json['date'], UtilCheckJsonTypes.string);
    tour_fid = UtilCheckJson.checkValue(json['tour_fid'], UtilCheckJsonTypes.string);
    tour_start = UtilCheckJson.checkValue(json['tour_start'], UtilCheckJsonTypes.string);
    tour_end = UtilCheckJson.checkValue(json['tour_end'], UtilCheckJsonTypes.string);
    duration_from = UtilCheckJson.checkValue(json['duration_from'], UtilCheckJsonTypes.string);
    duration_until = UtilCheckJson.checkValue(json['duration_until'], UtilCheckJsonTypes.string);
    location_begin = UtilCheckJson.checkValue(json['location_begin'], UtilCheckJsonTypes.string);
    location_end = UtilCheckJson.checkValue(json['location_end'], UtilCheckJsonTypes.string);
    photo_taken = UtilCheckJson.checkValue(json['photo_taken'], UtilCheckJsonTypes.int);
    distance_coast = UtilCheckJson.checkValue(json['distance_coast'], UtilCheckJsonTypes.string);
    distance_coast_estimation_gps = UtilCheckJson.checkValue(json['distance_coast_estimation_gps'], UtilCheckJsonTypes.int);
    species_id = UtilCheckJson.checkValue(json['species_id'], UtilCheckJsonTypes.int);
    species_count = UtilCheckJson.checkValue(json['species_count'], UtilCheckJsonTypes.int);
    juveniles = UtilCheckJson.checkValue(json['juveniles'], UtilCheckJsonTypes.int);
    calves = UtilCheckJson.checkValue(json['calves'], UtilCheckJsonTypes.int);
    newborns = UtilCheckJson.checkValue(json['newborns'], UtilCheckJsonTypes.int);
    behaviours = UtilCheckJson.checkValue(json['behaviours'], UtilCheckJsonTypes.string);
    subgroups = UtilCheckJson.checkValue(json['subgroups'], UtilCheckJsonTypes.int);
    group_structure_id = UtilCheckJson.checkValue(json['group_structure_id'], UtilCheckJsonTypes.int);
    reaction_id = UtilCheckJson.checkValue(json['reaction_id'], UtilCheckJsonTypes.int);
    freq_behaviour = UtilCheckJson.checkValue(json['freq_behaviour'], UtilCheckJsonTypes.string);
    recognizable_animals = UtilCheckJson.checkValue(json['recognizable_animals'], UtilCheckJsonTypes.string);
    other_species = UtilCheckJson.checkValue(json['other_species'], UtilCheckJsonTypes.string);
    other = UtilCheckJson.checkValue(json['other'], UtilCheckJsonTypes.string);
    other_vehicle = UtilCheckJson.checkValue(json['other_vehicle'], UtilCheckJsonTypes.string);
    note = UtilCheckJson.checkValue(json['note'], UtilCheckJsonTypes.string);
    image = UtilCheckJson.checkValue(json['image'], UtilCheckJsonTypes.string);
    syncStatus = UtilCheckJson.checkValue(json['syncStatus'], UtilCheckJsonTypes.int);
    sightingType = UtilCheckJson.checkValue(json['sightingType'], UtilCheckJsonTypes.int);

    if (json.containsKey('beaufort_wind_old') && json['beaufort_wind_old'] != 0 && beaufort_wind == '') {
      beaufort_wind = "${json['beaufort_wind_old']}";
    }
  }

  /// toJson
  Map<String, dynamic> toJson(bool withId, bool withSyncStatus, bool? forSync) {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (withId) {
      data['id'] = id;
    }

    data['unid'] = unid;
    data['creater_id'] = creater_id;
    data['vehicle_id'] = vehicle_id;
    data['vehicle_driver_id'] = vehicle_driver_id;
    data['beaufort_wind'] = beaufort_wind;

    try {
      if (date!.contains('/')) {
        var parts = date!.split('/');

        date = '${parts[2]}-${parts[0]}-${parts[1]}';
      }

      DateTime tDate = DateTime.parse(date!);
      date = DateFormat("yyyy-MM-dd").format(tDate.toLocal());
    } catch(e) {
      if (kDebugMode) {
        print('Sighting::toJson: date parsing error:');
        print(e);
      }
    }

    if (tour_fid != null) {
      tour_fid = UtilTourFid.convertTourFid(tour_fid!);
    }

    data['date'] = date;
    data['tour_fid'] = tour_fid ?? "";
    data['tour_start'] = tour_start;
    data['tour_end'] = tour_end;
    data['duration_from'] = duration_from;
    data['duration_until'] = duration_until;
    data['location_begin'] = location_begin;
    data['location_end'] = location_end;
    data['photo_taken'] = photo_taken;
    data['distance_coast'] = distance_coast;
    data['distance_coast_estimation_gps'] = distance_coast_estimation_gps;
    data['species_id'] = species_id;
    data['species_count'] = species_count;
    data['juveniles'] = juveniles;
    data['calves'] = calves;
    data['newborns'] = newborns;
    data['behaviours'] = behaviours;
    data['subgroups'] = subgroups;
    data['group_structure_id'] = group_structure_id;
    data['reaction_id'] = reaction_id;
    data['freq_behaviour'] = freq_behaviour;
    data['recognizable_animals'] = recognizable_animals;
    data['other_species'] = other_species;

    // only for repairing a bug
    if (forSync != null) {
      if (forSync) {
        Map<String, dynamic> newdata = {};
        Map<String, dynamic> olddata = jsonDecode(other_species!);
        final SpeciesController _speciesController = Get.find<SpeciesController>();

        olddata.forEach((key, value) {
          if (value != "") {
            var species = _speciesController.getSpeciesById(int.parse(value));

            if (species != null) {
              var orgid = species.orgid;
              newdata["$key"] = "$orgid";
            }
          }
        });

        data['other_species'] = const JsonEncoder().convert(newdata);
      }
    }

    data['other'] = other;
    data['other_vehicle'] = other_vehicle;
    data['note'] = note;
    data['image'] = image;

    // reset old field
    data['beaufort_wind_old'] = 0;

    if (withSyncStatus) {
      data['syncStatus'] = syncStatus;
    }

    if (sightingType != null) {
      data['sightingType'] = sightingType;
    } else {
      data['sightingType'] = Sighting.TYPE_NORMAL;
    }

    return data;
  }

  Color validateColor() {
    if (date == null || date == "") {
      return Colors.red;
    }

    if (tour_start == null || tour_start == "" || tour_start == "null") {
      return Colors.red;
    }

    if (tour_end == null || tour_end == "" || tour_end == "null") {
      return Colors.yellow;
    }

    if (duration_from == null || duration_from == "" || duration_from == "null") {
      return Colors.red;
    }

    if (location_begin == null || location_begin == "" || location_begin == "null") {
      return Colors.red;
    }

    if (location_end == null || location_end == "" || location_end == "null") {
      return Colors.yellow;
    }

    if (other != null) {
      List<String> tortoiseList = [
        'Caretta caretta',
        'Dermochelys coriacea',
        'Chelonia mydas',
        'Eretmochelys imbricata'
      ];

      if (tortoiseList.indexOf(other!) > -1) {
        return Colors.green;
      }
    }

    if (species_count == 0) {
      return Colors.red;
    }

    return kPrimaryHeaderColor;
  }
}