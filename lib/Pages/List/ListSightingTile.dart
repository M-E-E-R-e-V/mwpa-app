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


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: sighting.validateColor()
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _speciesController.getSpeciesName(sighting.species_id!),
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
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
                          color: Colors.grey[200],
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeString,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[100]
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
                          color: Colors.grey[200],
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locationString,
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[100]
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
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
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