import 'package:intl/intl.dart';
import 'package:mwpaapp/Models/TourPref.dart';

/// UtilTourTracking - rules for the local tour tracking points.
class UtilTourTracking {

  /// canResumeHomeAreaTour - whether the home area tour [stored] before an
  /// app restart is continued instead of starting a new tour.
  ///
  /// Only a tour of today is resumed, and only while the current tour
  /// settings ([currentTour]) still use the home area mode.
  static bool canResumeHomeAreaTour({
    required TourPref? stored,
    required TourPref? currentTour,
    required DateTime now,
  }) {
    if (stored == null || (currentTour?.use_home_area ?? 0) < 1) {
      return false;
    }

    if ((stored.tour_start ?? '').isEmpty) {
      return false;
    }

    return stored.date == DateFormat("yyyy-MM-dd").format(now);
  }

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
