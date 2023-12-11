import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

class SightingTourTrackingCheckResponse extends DefaultReturn {
  final bool? isComplete;
  final bool? canDelete;

  SightingTourTrackingCheckResponse({required super.statusCode, super.msg, this.isComplete, this.canDelete});

  factory SightingTourTrackingCheckResponse.fromJson(Map<String, dynamic> json) {
    String? msg;
    bool? isComplete;
    bool? canDelete;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    if (json.containsKey('isComplete')) {
      isComplete = json['isComplete'];
    }

    if (json.containsKey('canDelete')) {
      canDelete = json['canDelete'];
    }

    return SightingTourTrackingCheckResponse(
        statusCode: json['statusCode'],
        msg: msg,
        isComplete: isComplete,
        canDelete: canDelete
    );
  }
}