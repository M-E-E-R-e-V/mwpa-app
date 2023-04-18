
class SightingTourTracking {
  final String? unid;
  final String? tour_fid;
  final String? location;
  final String? date;

  SightingTourTracking({
    this.unid,
    this.tour_fid,
    this.location,
    this.date
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['unid'] = unid;
    data['tour_fid'] = tour_fid;
    data['location'] = location;
    data['date'] = date;

    return data;
  }
}