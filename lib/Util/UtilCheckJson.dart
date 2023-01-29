enum UtilCheckJsonTypes {
  int,
  string
}

class UtilCheckJson {
  static dynamic checkValue(dynamic val, UtilCheckJsonTypes type) {
    switch (type) {
      case UtilCheckJsonTypes.int:
        if (val == null) {
          return 0;
        }

        if (val is String) {
          return int.parse(val.trim());
        } else if (val is bool) {
          return val ? 1 : 0;
        }

        return val;

      default:
        if (val == null) {
          return "";
        }

        if (val is int || val is double) {
          return "$val";
        }

        return val;
    }
  }
}