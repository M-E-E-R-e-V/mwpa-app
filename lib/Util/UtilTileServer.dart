class UtilTileServer {
  static final yourMapBoxAccessToken = '';

  static String mapbox(int z, int x, int y) {
    //Mapbox Streets
    final url =
        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/$z/$x/$y?access_token=$yourMapBoxAccessToken';

    return url;
  }

  static String openstreetmap(int z, int x, int y) {
    final url = 'http://a.tile.openstreetmap.org/$z/$x/$y.png';

    return url;
  }
}