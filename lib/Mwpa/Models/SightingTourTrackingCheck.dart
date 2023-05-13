/// SightingTourTrackingCheck
class SightingTourTrackingCheck {
  final String tour_fid;
  final int count;

  const SightingTourTrackingCheck({required this.tour_fid, required this.count});

  /// toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['tour_fid'] = tour_fid;
    data['count'] = count;

    return data;
  }
}