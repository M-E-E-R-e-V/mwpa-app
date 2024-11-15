import 'dart:math';
import 'dart:ui';

import 'package:geolocator/geolocator.dart';

/// UtilLocationString
class UtilLocationString {
  String lat;
  String lon;

  UtilLocationString({required this.lat, required this.lon});

  /// toLocationDouble
  UtilLocationDouble toLocationDouble() {
    return UtilLocationDouble(lat: double.parse(lat), lon: double.parse(lon));
  }
}

/// UtilLocationDouble
class UtilLocationDouble {
  double lat;
  double lon;

  UtilLocationDouble({required this.lat, required this.lon});

  /// toLocationString
  UtilLocationString toLocationString() {
    return UtilLocationString(lat: "$lat", lon: "$lon");
  }

  /// position to location double
  static UtilLocationDouble positionToLocationDouble(Position position) {
    return UtilLocationDouble(
      lat: position.latitude,
      lon: position.longitude,
    );
  }

}

/// UtilLocationPolygon
class UtilLocationPolygon {

  /// is point in polygon
  static bool isPointInPolygon(UtilLocationDouble point, List<UtilLocationDouble> polygon) {
    int count = 0;

    for (int i = 0; i < polygon.length; i++) {
      UtilLocationDouble vertex1 = polygon[i];
      UtilLocationDouble vertex2 = polygon[(i + 1) % polygon.length];

      if (_isIntersecting(point, vertex1, vertex2)) {
        count++;
      }
    }

    return count % 2 == 1;
  }

  static bool _isIntersecting(UtilLocationDouble point, UtilLocationDouble vertex1, UtilLocationDouble vertex2) {
    if (vertex1.lat > vertex2.lat) {
      UtilLocationDouble temp = vertex1;
      vertex1 = vertex2;
      vertex2 = temp;
    }

    if (point.lat == vertex1.lat || point.lat == vertex2.lat) {
      point = UtilLocationDouble(lat: point.lat + 0.00001, lon: point.lon);
    }

    if (point.lat > vertex2.lat || point.lat < vertex1.lat || point.lon >= max(vertex1.lon, vertex2.lon)) {
      return false;
    }

    if (point.lon < min(vertex1.lon, vertex2.lon)) {
      return true;
    }

    double mEdge = (vertex2.lon - vertex1.lon) / (vertex2.lat - vertex1.lat);
    double mPoint = (point.lon - vertex1.lon) / (point.lat - vertex1.lat);

    return mPoint >= mEdge;
  }

}