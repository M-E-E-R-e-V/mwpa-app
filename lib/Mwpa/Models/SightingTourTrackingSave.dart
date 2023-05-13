
import 'package:mwpaapp/Models/TourTracking.dart';
import 'package:mwpaapp/Mwpa/Models/SightingTourTracking.dart';

/// SightingTourTrackingSave
class SightingTourTrackingSave {
  List<SightingTourTracking> list;

  SightingTourTrackingSave({required this.list});

  /// fromTrackingList
  static SightingTourTrackingSave fromTrackingList(List<TourTracking> trackList) {
    List<SightingTourTracking> tList = [];

    for (var entry in trackList) {
      tList.add(SightingTourTracking(
        unid: entry.uuid,
        tour_fid: entry.tour_fid,
        date: entry.date,
        location: entry.location
      ));
    }

    return SightingTourTrackingSave(list: tList);
  }

  /// toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    var list = [];

    for (var track in this.list) {
      list.add(track.toJson());
    }

    data['list'] = list;

    return data;
  }
}