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
          return int.parse(val);
        }

        return val;

      default:
        if (val == null) {
          return "";
        }

        if (val is int) {
          return "$val";
        }

        return val;
    }
  }
}