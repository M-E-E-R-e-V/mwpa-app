import 'package:flutter/material.dart';
import 'package:mwpaapp/Constants.dart';

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
  int? behaviour_id;
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
    this.behaviour_id,
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
    id = json['id'];
    unid = json['unid'];
    vehicle_id = json['vehicle_id'];
    vehicle_driver_id = json['vehicle_driver_id'];
    date = json['date'];
    tour_start = json['tour_start'];
    tour_end = json['tour_end'];
    duration_from = json['duration_from'];
    duration_until = json['duration_until'];
    location_begin = json['location_begin'];
    location_end = json['location_end'];
    photo_taken = json['photo_taken'];
    distance_coast = json['distance_coast'];
    distance_coast_estimation_gps = json['distance_coast_estimation_gps'];
    species_id = json['species_id'];
    species_count = json['species_count'];
    juveniles = json['juveniles'];
    calves = json['calves'];
    newborns = json['newborns'];
    behaviour_id = json['behaviour_id'];
    subgroups = json['subgroups'];
    reaction_id = json['reaction_id'];
    freq_behaviour = json['freq_behaviour'];
    recognizable_animals = json['recognizable_animals'];
    other_species = json['other_species'];
    other = json['other'];
    other_vehicle = json['other_vehicle'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
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
    data['behaviour_id'] = behaviour_id;
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

    if (tour_start == null || tour_start == "") {
      return Colors.red;
    }

    if (tour_end == null || tour_end == "") {
      return Colors.yellow;
    }

    if (duration_from == null || duration_from == "") {
      return Colors.red;
    }



    return kPrimaryHeaderColor;
  }
}