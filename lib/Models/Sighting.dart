import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';
import 'package:mwpaapp/Util/UtilCheckJson.dart';

class Sighting {

  int? id;
  String? unid;
  int? vehicle_id;
  int? vehicle_driver_id;
  String? date;
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
  int? reaction_id;
  String? freq_behaviour;
  String? recognizable_animals;
  String? other_species;
  String? other;
  String? other_vehicle;
  String? note;

  Sighting({
    this.id,
    required this.unid,
    this.vehicle_id,
    this.vehicle_driver_id,
    this.date,
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
    this.reaction_id,
    this.freq_behaviour,
    this.recognizable_animals,
    this.other_species,
    this.other,
    this.other_vehicle,
    this.note
  });

  Sighting.fromJson(Map<String, dynamic> json) {
    id = UtilCheckJson.checkValue(json['id'], UtilCheckJsonTypes.int);
    unid = UtilCheckJson.checkValue(json['unid'], UtilCheckJsonTypes.string);
    vehicle_id = UtilCheckJson.checkValue(json['vehicle_id'], UtilCheckJsonTypes.int);
    vehicle_driver_id = UtilCheckJson.checkValue(json['vehicle_driver_id'], UtilCheckJsonTypes.int);
    date = UtilCheckJson.checkValue(json['date'], UtilCheckJsonTypes.string);
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
    reaction_id = UtilCheckJson.checkValue(json['reaction_id'], UtilCheckJsonTypes.int);
    freq_behaviour = UtilCheckJson.checkValue(json['freq_behaviour'], UtilCheckJsonTypes.string);
    recognizable_animals = UtilCheckJson.checkValue(json['recognizable_animals'], UtilCheckJsonTypes.string);
    other_species = UtilCheckJson.checkValue(json['other_species'], UtilCheckJsonTypes.string);
    other = UtilCheckJson.checkValue(json['other'], UtilCheckJsonTypes.string);
    other_vehicle = UtilCheckJson.checkValue(json['other_vehicle'], UtilCheckJsonTypes.string);
    note = UtilCheckJson.checkValue(json['note'], UtilCheckJsonTypes.string);
  }

  Map<String, dynamic> toJson(bool withId) {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (withId) {
      data['id'] = id;
    }

    data['unid'] = unid;
    data['vehicle_id'] = vehicle_id;
    data['vehicle_driver_id'] = vehicle_driver_id;
    data['date'] = date;
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
    data['newborns'] = newborns;
    data['behaviours'] = behaviours;
    data['subgroups'] = subgroups;
    data['reaction_id'] = reaction_id;
    data['freq_behaviour'] = freq_behaviour;
    data['recognizable_animals'] = recognizable_animals;
    data['other_species'] = other_species;
    data['other'] = other;
    data['other_vehicle'] = other_vehicle;
    data['note'] = note;

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

    return kPrimaryHeaderColor;
  }
}