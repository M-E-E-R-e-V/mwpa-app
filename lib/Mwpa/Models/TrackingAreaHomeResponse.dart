import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';
import 'package:mwpaapp/Mwpa/Models/TrackingAreaHomeData.dart';

class TrackingAreaHomeResponse extends DefaultReturn {

  final TrackingAreaHomeData? data;

  TrackingAreaHomeResponse({required super.statusCode, super.msg, this.data});

  factory TrackingAreaHomeResponse.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    TrackingAreaHomeData? data;

    if (json.containsKey('data')) {
      data = TrackingAreaHomeData.fromJson(json['data']);
    }

    return TrackingAreaHomeResponse(
        statusCode: json['statusCode'],
        msg: msg,
        data: data
    );
  }

}