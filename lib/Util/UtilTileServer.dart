/// UtilTileServer - tile source configuration for the map (flutter_map).
class UtilTileServer {
  /// OpenStreetMap standard tiles (HTTPS - plain HTTP is blocked by iOS ATS
  /// and Android cleartext rules). Usage policy:
  /// https://operations.osmfoundation.org/policies/tiles/
  static const openStreetMapUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Identifies the app towards the tile server (required by the OSM policy).
  static const userAgentPackageName = 'com.meer.mwpaapp';
}
