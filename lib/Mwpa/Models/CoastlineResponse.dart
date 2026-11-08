import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

/// CoastlineData - coast lines around the area of the organization
/// (`mobile/coastline`, OpenStreetMap natural=coastline). [status]: ok,
/// pending (the server is still loading them), error, no_area.
class CoastlineData {
  static const String statusOk = 'ok';
  static const String statusPending = 'pending';

  final String status;
  final String areaKey;
  final double south;
  final double west;
  final double north;
  final double east;

  /// one flat [lat, lon, lat, lon, ...] list per line
  final List<List<double>> lines;
  final int fetchDatetime;

  const CoastlineData({
    required this.status,
    required this.areaKey,
    required this.south,
    required this.west,
    required this.north,
    required this.east,
    required this.lines,
    required this.fetchDatetime,
  });

  factory CoastlineData.fromJson(Map<String, dynamic> json) {
    double d(String key) => (json[key] as num?)?.toDouble() ?? 0;

    return CoastlineData(
      status: json['status'] as String? ?? '',
      areaKey: json['area_key'] as String? ?? '',
      south: d('south'),
      west: d('west'),
      north: d('north'),
      east: d('east'),
      lines: [
        for (final line in (json['lines'] as List<dynamic>? ?? const []))
          [for (final v in line as List<dynamic>) (v as num).toDouble()],
      ],
      fetchDatetime: (json['fetch_datetime'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'area_key': areaKey,
        'south': south,
        'west': west,
        'north': north,
        'east': east,
        'lines': lines,
        'fetch_datetime': fetchDatetime,
      };
}

class CoastlineResponse extends DefaultReturn {
  final CoastlineData? data;

  CoastlineResponse({required super.statusCode, super.msg, this.data});

  factory CoastlineResponse.fromJson(Map<String, dynamic> json) {
    return CoastlineResponse(
      statusCode: json['statusCode'],
      msg: json['msg'] as String?,
      data: json['data'] == null ? null : CoastlineData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
