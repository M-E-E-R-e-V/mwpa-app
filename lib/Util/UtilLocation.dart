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

}