import 'package:geolocator/geolocator.dart';

/// Degrees, minutes and seconds of one coordinate (unsigned; the sign is
/// expressed by the hemisphere letter).
typedef Dms = ({int degrees, int minutes, double seconds});

class UtilPosition {
  /// toDms - [decimal] degrees as degrees/minutes/seconds, seconds rounded
  /// to 3 decimals (a rounding up to 60" carries into the minutes/degrees)
  static Dms toDms(double decimal) {
    final totalMs = (decimal.abs() * 3600 * 1000).round();
    final degrees = totalMs ~/ (3600 * 1000);
    final minutes = (totalMs % (3600 * 1000)) ~/ (60 * 1000);
    final seconds = (totalMs % (60 * 1000)) / 1000;

    return (degrees: degrees, minutes: minutes, seconds: seconds);
  }

  /// formatDms - e.g. N: 37° 25' 19.194" - W: 122° 5' 2.4"
  static String formatDms(double latitude, double longitude) {
    final lat = toDms(latitude);
    final lon = toDms(longitude);
    final keyLat = latitude < 0 ? "S" : "N";
    final keyLon = longitude < 0 ? "W" : "E";

    return "$keyLat: ${lat.degrees}° ${lat.minutes}' ${lat.seconds}\" - "
        "$keyLon: ${lon.degrees}° ${lon.minutes}' ${lon.seconds}\" ";
  }

  /// getStr - position for display
  static String getStr(Position pos) => formatDms(pos.latitude, pos.longitude);
}
