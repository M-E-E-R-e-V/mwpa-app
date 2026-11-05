/// UtilTourTracking - rules for the local tour tracking points.
class UtilTourTracking {

  /// How long confirmed tracking points of a tour are kept on the device.
  static const Duration localRetention = Duration(days: 30);

  /// canDeleteLocal - whether the local tracking points of a tour may be
  /// deleted after the server check.
  ///
  /// Never deletes data the server has not confirmed ([isComplete] false), so
  /// effort data can't get lost when a sync fails. Confirmed tours are deleted
  /// when the server allows it ([canDelete]) or when the latest tracking point
  /// ([latestDate], "yyyy-MM-dd HH:mm:ss") is older than [retention].
  static bool canDeleteLocal({
    required bool isComplete,
    bool? canDelete,
    String? latestDate,
    required DateTime now,
    Duration retention = localRetention,
  }) {
    if (!isComplete) {
      return false;
    }

    if (canDelete ?? false) {
      return true;
    }

    final latest = latestDate == null ? null : DateTime.tryParse(latestDate);

    if (latest == null) {
      return false;
    }

    return latest.isBefore(now.subtract(retention));
  }
}
