import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Components/DefaultButton.dart';
import 'package:mwpaapp/Controllers/LocationController.dart';
import 'package:mwpaapp/Controllers/SightingController.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Db/DBHelper.dart';
import 'package:mwpaapp/Dialog/InfoDialog.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';

import '../../Constants.dart';

class ListSightingTile extends StatelessWidget {

  final Sighting sighting;

  ListSightingTile(this.sighting, {Key? key}) : super(key: key);

  final LocationController _locationController = Get.find<LocationController>();
  final SpeciesController _speciesController = Get.find<SpeciesController>();
  final SightingController _sightingController = Get.find<SightingController>();

  @override
  Widget build(BuildContext context) {
    String timeString = "not set!";
    String locationString = "not set!";

    if (sighting.date != null) {
      DateTime tDate = DateTime.parse(sighting.date!);
      timeString = "${DateFormat.yMd().format(tDate.toLocal())} - ${sighting.duration_from!}";
    }

    if (sighting.location_begin != null) {
      try {
        Position tpos = Position.fromMap(jsonDecode(sighting.location_begin!));
        locationString = UtilPosition.getStr(tpos);
      }
      catch(loce) {
        print(loce);
      }
    }

    Color backgroundColor = sighting.validateColor();
    String? speciesName = _speciesController.getSpeciesName(sighting.species_id!);

    if (speciesName == null && sighting.other != null && sighting.other!.trim() != "") {
      speciesName = sighting.other?.trim();
    } else if(speciesName == null && sighting.note != null && sighting.note!.trim() != "") {
      speciesName = sighting.note?.trim();
    }

    if (speciesName == null) {
      backgroundColor = Colors.yellow;
      speciesName = "Specie not found";
    }

    List<Widget> symbols = [];

    if (sighting.subgroups != null && sighting.subgroups! > 0) {
      symbols.add(Icon(
        Icons.groups,
        color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[200] : Colors.grey[700],
        size: 18,
      ));
    }

    if ( (sighting.calves != null && sighting.calves! > 0) || (sighting.newborns != null && sighting.newborns! > 0)) {
      symbols.add(Icon(
        Icons.child_care,
        color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[200] : Colors.grey[700],
        size: 18,
      ));
    }

    if (sighting.note != null && sighting.note! != "") {
      symbols.add(Icon(
        Icons.notes,
        color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[200] : Colors.grey[700],
        size: 18,
      ));
    }

    if (symbols.isEmpty) {
      if (backgroundColor == kPrimaryHeaderColor) {
        symbols.add(Icon(
          Icons.done,
          color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[200] : Colors.grey[700],
          size: 18,
        ));
      }
    }

    if (backgroundColor != kPrimaryHeaderColor) {
      symbols.add(Icon(
        Icons.warning,
        color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[200] : Colors.grey[700],
        size: 18,
      ));
    }

    var endLocationEmpty = false;

    if (sighting.location_end == null || sighting.location_end == "" || sighting.location_end == "null" ) {
      endLocationEmpty = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: backgroundColor
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speciesName,
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: backgroundColor.computeLuminance() < 0.5 ? Colors.white : Colors.black
                        )
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[200] : Colors.grey[700],
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeString,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[100] : Colors.grey[700]
                            )
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[200] : Colors.grey[700],
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locationString,
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: 13,
                                  color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[100] : Colors.grey[700]
                              )
                          ),
                        )
                      ],
                    ),
                  ]
                )
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 0.5,
              color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[200]!.withOpacity(0.7) : Colors.grey[800]!.withOpacity(0.7),
            ),
            Column(
              children: !endLocationEmpty ? symbols : [
                DefaultButton(
                  buttonIcon: Icons.add_location_alt,
                  width: 22,
                  onTab: () {
                    if (_locationController.currentPosition == null) {
                      InfoDialog.show(context, 'Info', "Please wait for the GPS signal.");
                    } else {
                      sighting.location_end = jsonEncode(_locationController.currentPosition?.toJson());

                      if ( sighting.duration_until == null || sighting.duration_until == 'null' || sighting.duration_until == '') {
                        var timeValue = TimeOfDay.now();
                        var hour = "${timeValue.hour}";
                        var min = "${timeValue.minute}";

                        if (timeValue.hour < 10) {
                          hour = "0${timeValue.hour}";
                        }

                        if (timeValue.minute < 10) {
                          min = "0${timeValue.minute}";
                        }

                        sighting.duration_until = "$hour:$min";
                      }

                      _sightingController.updateSighting(tSighting: sighting);
                      _sightingController.getSightings();
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}