import 'package:geolocator/geolocator.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class UtilPosition {
  static String getStr(Position pos) {
    LatLongConverter converter = LatLongConverter();
    var latDms = converter.getDegreeFromDecimal(pos.latitude);
    var longDms = converter.getDegreeFromDecimal(pos.longitude);

    var keyLong = "E";
    var keyLat = "N";

    if (longDms[0] < 0) {
      keyLong = "W";
    }

    if (latDms[0] < 0) {
      keyLat = "S";
    }

    var latPart3 = double.parse((latDms[2]).toStringAsFixed(3));
    var longPart3 = double.parse((longDms[2]).toStringAsFixed(3));

    return "$keyLat: ${latDms[0]}° ${latDms[1]}' $latPart3\" - $keyLong: ${longDms[0]}° ${longDms[1]}' $longPart3\" ";
  }
}