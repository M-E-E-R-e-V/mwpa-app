import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mwpaapp/Controllers/SpeciesController.dart';
import 'package:mwpaapp/Models/Sighting.dart';
import 'package:mwpaapp/Util/UtilPosition.dart';

class ListSightingTile extends StatelessWidget {

  final Sighting sighting;

  ListSightingTile(this.sighting, {Key? key}) : super(key: key);


  final SpeciesController _speciesController = Get.find<SpeciesController>();

  @override
  Widget build(BuildContext context) {
    String timeString = "not set!";
    String locationString = "not set!";

    if (sighting.date != null) {
      DateTime tDate = DateTime.parse(sighting.date!);
      timeString = "${DateFormat.yMd().format(tDate)} - ${sighting.duration_from!}";
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

    if (sighting.other != null && sighting.other!.trim() != "") {
      speciesName = sighting.other;
    } else if(sighting.note != null && sighting.note!.trim() != "") {
      speciesName = sighting.note;
    } else {
      speciesName ??= "Specie not found";
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
                      speciesName!,
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
              color: Colors.grey[200]!.withOpacity(0.7),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                "TODO",
                style: GoogleFonts.lato(
                  textStyle:  TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor.computeLuminance() < 0.5 ? Colors.grey[100] : Colors.grey[700]
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}