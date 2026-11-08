
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:geolocator/geolocator.dart';
import 'package:mwpaapp/Mwpa/Models/CoastlineResponse.dart';
import 'package:mwpaapp/Util/AppLog.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// CoastLines - the coast lines of the organization's area in memory
/// (from the server, `mobile/coastline`) for distance lookups
class CoastLines {
  static const double metersPerDegree = 111320.0;

  final CoastlineData data;
  final List<Float64List> _lines;

  /// per line: south, west, north, east
  final List<Float64List> _boxes;

  CoastLines(this.data)
      : _lines = [for (final l in data.lines) Float64List.fromList(l)],
        _boxes = [for (final l in data.lines) _boxOf(l)];

  static Float64List _boxOf(List<double> line) {
    var south = double.infinity, west = double.infinity;
    var north = -double.infinity, east = -double.infinity;

    for (var i = 0; i + 1 < line.length; i += 2) {
      south = math.min(south, line[i]);
      north = math.max(north, line[i]);
      west = math.min(west, line[i + 1]);
      east = math.max(east, line[i + 1]);
    }

    return Float64List.fromList([south, west, north, east]);
  }

  /// distanceMeters - meters from [lat]/[lon] to the nearest coast line;
  /// null when the point is outside the loaded box or a coast outside the
  /// box could be nearer than the nearest one inside
  double? distanceMeters(double lat, double lon) {
    if (lat < data.south || lat > data.north || lon < data.west || lon > data.east) {
      return null;
    }

    // local metric projection around the point (error < 0.5 % within 100 km)
    final mx = metersPerDegree * math.cos(lat * math.pi / 180);
    const my = metersPerDegree;

    final toEdge = [
      (lat - data.south) * my,
      (data.north - lat) * my,
      (lon - data.west) * mx,
      (data.east - lon) * mx,
    ].reduce(math.min);

    var best = double.infinity;

    for (var n = 0; n < _lines.length; n++) {
      final box = _boxes[n];
      final dx = lon < box[1] ? (box[1] - lon) * mx : (lon > box[3] ? (lon - box[3]) * mx : 0.0);
      final dy = lat < box[0] ? (box[0] - lat) * my : (lat > box[2] ? (lat - box[2]) * my : 0.0);

      if (dx * dx + dy * dy >= best * best) {
        continue;
      }

      final line = _lines[n];
      var ax = (line[1] - lon) * mx;
      var ay = (line[0] - lat) * my;

      if (line.length == 2) {
        best = math.min(best, math.sqrt(ax * ax + ay * ay));
        continue;
      }

      for (var i = 2; i + 1 < line.length; i += 2) {
        final bx = (line[i + 1] - lon) * mx;
        final by = (line[i] - lat) * my;
        final sx = bx - ax, sy = by - ay;
        final len = sx * sx + sy * sy;
        var t = len == 0 ? 0.0 : -(ax * sx + ay * sy) / len;
        t = t < 0 ? 0 : (t > 1 ? 1 : t);
        final px = ax + t * sx, py = ay + t * sy;
        final d = math.sqrt(px * px + py * py);

        if (d < best) {
          best = d;
        }

        ax = bx;
        ay = by;
      }
    }

    return best <= toEdge ? best : null;
  }
}

class UtilDistanceCoast {

  /// file in the app support dir with the coast lines of the last sync
  static const String fileName = 'coastline.json';

  /// the server is asked at most once per interval (pending: every sync)
  static const int checkIntervalSec = 24 * 60 * 60;

  static CoastLines? _coast;
  static int _checkedAt = 0;
  static File? _file;

  /// coast lines from the server, null until the first successful sync
  static CoastLines? get coast => _coast;

  /// init - loads the coast lines of the last sync (main, before runApp);
  /// [dir] for tests
  static Future<void> init({Directory? dir}) async {
    _coast = null;
    _checkedAt = 0;

    try {
      _file = File(p.join((dir ?? await getApplicationSupportDirectory()).path, fileName));

      if (!await _file!.exists()) {
        return;
      }

      final json = jsonDecode(await _file!.readAsString()) as Map<String, dynamic>;
      _checkedAt = (json['checked_at'] as num?)?.toInt() ?? 0;

      if (json['data'] != null) {
        _coast = CoastLines(CoastlineData.fromJson(json['data'] as Map<String, dynamic>));
      }
    } catch (error) {
      AppLog.w('Coast', 'coast lines not loaded', error);
    }
  }

  /// needsCheck - ask the server for the coast lines (again)
  static bool needsCheck(int nowSec) => nowSec - _checkedAt >= checkIntervalSec;

  /// store - remember the check at [nowSec]; new coast lines when [data] is
  /// given (old ones stay when the server has none)
  static Future<void> store(int nowSec, [CoastlineData? data]) async {
    _checkedAt = nowSec;

    if (data != null) {
      _coast = CoastLines(data);
    }

    try {
      await _file?.writeAsString(jsonEncode({
        'checked_at': _checkedAt,
        'data': _coast?.data.toJson(),
      }));
    } catch (error) {
      AppLog.w('Coast', 'coast lines not saved', error);
    }
  }

  /// meters per nautical mile
  static const double metersPerNm = 1852.0;

  /// metersToNmText - stored distance (meters, as string) as nautical miles
  /// with at most 2 decimals; '' when [meters] is empty or not a number.
  static String metersToNmText(String meters) {
    final m = double.tryParse(meters.trim());

    if (m == null) {
      return '';
    }

    return '${double.parse((m / metersPerNm).toStringAsFixed(2))}';
  }

  /// nmTextToMeters - typed nautical miles ('2.5' or '2,5') as meters
  /// string to store (rounded to whole meters); '' for empty input, null
  /// when [text] is not a valid number.
  static String? nmTextToMeters(String text) {
    final t = text.trim().replaceAll(',', '.');

    if (t.isEmpty) {
      return '';
    }

    final nm = double.tryParse(t);

    if (nm == null || nm < 0) {
      return null;
    }

    return '${(nm * metersPerNm).round()}';
  }

  // https://www.geoplaner.de/
  // https://pub.dev/packages/gpx

  /// Fallback until the server delivers coast lines: points (lat, lon) of
  /// the south-west coast of La Gomera only (Valle Gran Rey - Playa
  /// Santiago; formerly an inline GPX file with 368 waypoints).
  static const List<(double, double)> coastPoints = [
    (28.08153, -17.33033),
    (28.081, -17.32985),
    (28.08055, -17.329),
    (28.08028, -17.32839),
    (28.08017, -17.32715),
    (28.08002, -17.32646),
    (28.08024, -17.32565),
    (28.0799, -17.32487),
    (28.07934, -17.32389),
    (28.07847, -17.32329),
    (28.07767, -17.32281),
    (28.07676, -17.32204),
    (28.07642, -17.32135),
    (28.07616, -17.32062),
    (28.07535, -17.32025),
    (28.07468, -17.31998),
    (28.0743, -17.31985),
    (28.07381, -17.31955),
    (28.07343, -17.31942),
    (28.07283, -17.31938),
    (28.07241, -17.31929),
    (28.07218, -17.31904),
    (28.07158, -17.31878),
    (28.07128, -17.31895),
    (28.07097, -17.31916),
    (28.07078, -17.31904),
    (28.07048, -17.31882),
    (28.07025, -17.31852),
    (28.0698, -17.31856),
    (28.0695, -17.31856),
    (28.06893, -17.31843),
    (28.0687, -17.31861),
    (28.06821, -17.31869),
    (28.06802, -17.31908),
    (28.06768, -17.31938),
    (28.06719, -17.32007),
    (28.067, -17.32015),
    (28.06673, -17.31985),
    (28.06617, -17.31989),
    (28.06583, -17.32002),
    (28.06545, -17.32011),
    (28.06507, -17.32054),
    (28.06495, -17.32092),
    (28.06465, -17.32071),
    (28.06435, -17.32075),
    (28.0642, -17.32037),
    (28.06401, -17.32002),
    (28.06363, -17.31998),
    (28.06359, -17.31977),
    (28.06348, -17.31959),
    (28.06333, -17.31908),
    (28.06333, -17.31908),
    (28.0631, -17.31882),
    (28.06291, -17.31865),
    (28.06249, -17.31891),
    (28.06227, -17.31882),
    (28.06208, -17.31904),
    (28.06178, -17.31916),
    (28.0614, -17.31955),
    (28.06098, -17.31951),
    (28.06041, -17.31959),
    (28.05992, -17.31947),
    (28.05958, -17.31934),
    (28.05935, -17.31904),
    (28.05882, -17.31938),
    (28.05818, -17.31998),
    (28.05761, -17.32024),
    (28.05761, -17.31977),
    (28.0586, -17.31904),
    (28.05882, -17.31831),
    (28.05935, -17.3177),
    (28.05988, -17.31693),
    (28.05943, -17.3165),
    (28.05939, -17.31607),
    (28.0592, -17.3159),
    (28.05879, -17.3156),
    (28.05822, -17.31504),
    (28.0578, -17.31496),
    (28.05735, -17.31449),
    (28.05742, -17.31384),
    (28.05712, -17.31354),
    (28.05693, -17.31333),
    (28.05633, -17.3132),
    (28.0558, -17.31298),
    (28.05519, -17.31277),
    (28.05474, -17.31255),
    (28.05424, -17.31273),
    (28.05386, -17.31255),
    (28.05345, -17.31187),
    (28.05299, -17.31122),
    (28.05254, -17.31075),
    (28.05201, -17.31015),
    (28.05212, -17.30946),
    (28.05197, -17.30873),
    (28.05159, -17.30869),
    (28.05148, -17.30839),
    (28.05144, -17.308),
    (28.0514, -17.30762),
    (28.05186, -17.30684),
    (28.05197, -17.30607),
    (28.05163, -17.30543),
    (28.05152, -17.30453),
    (28.05133, -17.30371),
    (28.05099, -17.30324),
    (28.05061, -17.30311),
    (28.05031, -17.30324),
    (28.05, -17.30294),
    (28.04944, -17.30225),
    (28.04917, -17.30186),
    (28.04921, -17.30079),
    (28.04993, -17.2995),
    (28.05019, -17.29877),
    (28.05004, -17.29817),
    (28.04932, -17.29761),
    (28.04902, -17.29706),
    (28.04875, -17.29676),
    (28.04841, -17.29637),
    (28.04773, -17.29577),
    (28.04735, -17.2953),
    (28.04698, -17.29465),
    (28.04682, -17.29457),
    (28.04637, -17.29397),
    (28.04637, -17.29341),
    (28.0466, -17.29281),
    (28.04675, -17.29216),
    (28.0469, -17.2916),
    (28.04645, -17.29109),
    (28.04607, -17.29066),
    (28.04561, -17.29045),
    (28.04486, -17.29057),
    (28.04383, -17.29075),
    (28.04311, -17.29087),
    (28.04213, -17.29066),
    (28.04137, -17.29027),
    (28.04027, -17.28963),
    (28.03948, -17.28911),
    (28.03846, -17.28937),
    (28.03804, -17.28937),
    (28.03793, -17.28886),
    (28.03838, -17.28808),
    (28.03884, -17.28718),
    (28.0391, -17.28641),
    (28.03876, -17.28611),
    (28.03854, -17.28587),
    (28.03861, -17.28487),
    (28.03876, -17.28414),
    (28.03853, -17.28366),
    (28.03778, -17.28358),
    (28.03823, -17.28255),
    (28.03868, -17.28165),
    (28.03838, -17.28083),
    (28.03823, -17.28036),
    (28.03815, -17.27971),
    (28.03755, -17.28014),
    (28.03725, -17.2798),
    (28.03672, -17.2795),
    (28.03668, -17.27911),
    (28.03672, -17.27834),
    (28.03675, -17.27757),
    (28.03656, -17.27662),
    (28.03596, -17.27606),
    (28.03581, -17.27568),
    (28.03577, -17.27508),
    (28.03603, -17.27422),
    (28.03607, -17.27332),
    (28.03581, -17.27293),
    (28.03535, -17.27276),
    (28.03486, -17.2728),
    (28.03426, -17.27323),
    (28.03323, -17.27375),
    (28.03232, -17.27366),
    (28.03145, -17.27357),
    (28.03081, -17.27357),
    (28.03039, -17.27327),
    (28.03005, -17.27272),
    (28.02945, -17.27293),
    (28.02873, -17.2731),
    (28.02782, -17.27233),
    (28.0274, -17.27259),
    (28.0271, -17.27254),
    (28.02661, -17.27186),
    (28.02619, -17.27156),
    (28.02596, -17.27121),
    (28.02562, -17.27104),
    (28.02528, -17.2704),
    (28.02483, -17.26941),
    (28.02494, -17.26812),
    (28.0249, -17.26757),
    (28.02487, -17.26696),
    (28.02468, -17.26602),
    (28.0254, -17.26482),
    (28.0257, -17.26332),
    (28.02566, -17.26151),
    (28.02551, -17.2604),
    (28.02528, -17.25928),
    (28.02547, -17.25795),
    (28.02649, -17.2564),
    (28.02593, -17.25585),
    (28.02562, -17.25503),
    (28.02577, -17.254),
    (28.02574, -17.25284),
    (28.02547, -17.25181),
    (28.02502, -17.25031),
    (28.02415, -17.24984),
    (28.02316, -17.24936),
    (28.02229, -17.24945),
    (28.02172, -17.24863),
    (28.02172, -17.2476),
    (28.02169, -17.24683),
    (28.02142, -17.2461),
    (28.021, -17.24584),
    (28.02032, -17.24524),
    (28.0201, -17.24481),
    (28.01998, -17.24378),
    (28.0201, -17.2428),
    (28.02059, -17.24232),
    (28.02047, -17.24129),
    (28.02097, -17.23988),
    (28.02153, -17.23928),
    (28.02165, -17.23837),
    (28.0218, -17.23726),
    (28.02214, -17.23649),
    (28.02225, -17.23515),
    (28.02233, -17.23447),
    (28.024, -17.23503),
    (28.02521, -17.23421),
    (28.02536, -17.23339),
    (28.0254, -17.23206),
    (28.02559, -17.23082),
    (28.02585, -17.22966),
    (28.02646, -17.22811),
    (28.02638, -17.2273),
    (28.02574, -17.22618),
    (28.02562, -17.22571),
    (28.02543, -17.22489),
    (28.02555, -17.22365),
    (28.02555, -17.22296),
    (28.02559, -17.2215),
    (28.02562, -17.21979),
    (28.02509, -17.21919),
    (28.02551, -17.21764),
    (28.02593, -17.21691),
    (28.02725, -17.21554),
    (28.02755, -17.21438),
    (28.0274, -17.21318),
    (28.02736, -17.21215),
    (28.02714, -17.21099),
    (28.02642, -17.20991),
    (28.02574, -17.20961),
    (28.02471, -17.20905),
    (28.02437, -17.20832),
    (28.0243, -17.20669),
    (28.02418, -17.20549),
    (28.02411, -17.20399),
    (28.02392, -17.20283),
    (28.02362, -17.20176),
    (28.02418, -17.20081),
    (28.02407, -17.19974),
    (28.02396, -17.19837),
    (28.02581, -17.19785),
    (28.08233, -17.3321),
    (28.08184, -17.33283),
    (28.08136, -17.33287),
    (28.08017, -17.33122),
    (28.07989, -17.33139),
    (28.08074, -17.33253),
    (28.0804, -17.3332),
    (28.07981, -17.3332),
    (28.07949, -17.33302),
    (28.07925, -17.33279),
    (28.07908, -17.33298),
    (28.07809, -17.33062),
    (28.07796, -17.33088),
    (28.07934, -17.33403),
    (28.08034, -17.33403),
    (28.08118, -17.33453),
    (28.08231, -17.33476),
    (28.0835, -17.33618),
    (28.08316, -17.33566),
    (28.08441, -17.3371),
    (28.08462, -17.33787),
    (28.08557, -17.33738),
    (28.08585, -17.33781),
    (28.08575, -17.33807),
    (28.08583, -17.33867),
    (28.086, -17.33923),
    (28.08706, -17.33953),
    (28.08795, -17.33981),
    (28.08888, -17.33957),
    (28.0903, -17.33983),
    (28.09001, -17.33974),
    (28.09149, -17.34036),
    (28.09247, -17.34069),
    (28.09361, -17.34129),
    (28.09442, -17.34197),
    (28.09472, -17.34249),
    (28.09448, -17.34292),
    (28.09444, -17.34309),
    (28.0944, -17.34369),
    (28.09436, -17.34418),
    (28.09431, -17.34438),
    (28.09497, -17.34479),
    (28.09559, -17.34472),
    (28.09585, -17.34532),
    (28.09612, -17.3456),
    (28.09634, -17.34601),
    (28.09635, -17.34683),
    (28.09632, -17.34654),
    (28.0967, -17.34736),
    (28.09695, -17.34772),
    (28.09726, -17.34796),
    (28.09744, -17.34822),
    (28.09783, -17.3485),
    (28.09791, -17.34874),
    (28.09822, -17.34893),
    (28.09868, -17.34888),
    (28.0991, -17.34866),
    (28.0996, -17.34882),
    (28.09984, -17.34849),
    (28.09993, -17.34816),
    (28.10042, -17.34782),
    (28.10079, -17.34756),
    (28.10131, -17.34723),
    (28.10201, -17.34717),
    (28.10255, -17.34714),
    (28.10317, -17.34694),
    (28.10368, -17.34692),
    (28.10414, -17.34685),
    (28.10483, -17.34662),
    (28.10552, -17.34669),
    (28.1046, -17.34666),
    (28.10628, -17.34693),
    (28.10666, -17.34715),
    (28.10725, -17.34706),
    (28.10801, -17.34692),
    (28.10854, -17.34692),
    (28.10906, -17.34681),
    (28.10956, -17.34694),
    (28.11034, -17.34704),
    (28.11085, -17.3471),
    (28.11163, -17.34722),
    (28.11218, -17.34737),
    (28.11263, -17.34791),
    (28.11269, -17.34724),
    (28.11326, -17.34723),
    (28.11353, -17.34674),
    (28.1145, -17.34657),
    (28.11497, -17.34647),
    (28.11587, -17.34659),
    (28.11649, -17.34686),
    (28.11707, -17.34721),
    (28.11701, -17.34775),
    (28.11745, -17.34777),
    (28.11751, -17.34748),
    (28.11802, -17.3475),
    (28.118, -17.34764),
    (28.11838, -17.34768),
    (28.11832, -17.34731),
    (28.11823, -17.34709),
    (28.11839, -17.34664),
    (28.11855, -17.34616),
    (28.11921, -17.34626),
    (28.1195, -17.346),
    (28.11962, -17.34569),
    (28.12015, -17.34576),
    (28.12051, -17.34599),
    (28.12106, -17.34595),
    (28.12131, -17.34571),
  ];

  /// distanceText - [getDistance] as the stored text (meters), '' when it
  /// is not known at [pos]
  static String distanceText(Position pos) {
    final meters = getDistance(pos);
    return meters == null ? '' : '$meters';
  }

  /// getDistance - meters from [pos] to the nearest coast. With coast lines
  /// from the server: null outside their area (no value is better than a
  /// wrong one). Without (older server, before the first sync): the nearest
  /// point of [coastPoints].
  static double? getDistance(Position pos) {
    final coast = _coast;

    if (coast != null) {
      return coast.distanceMeters(pos.latitude, pos.longitude);
    }

    var result = double.infinity;

    for (final (lat, lon) in coastPoints) {
      final distance = Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lon);

      if (distance < result) {
        result = distance;
      }
    }

    return result;
  }
}
