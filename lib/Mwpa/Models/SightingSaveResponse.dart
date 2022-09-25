import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

class SightingSaveResponse extends DefaultReturn {

  SightingSaveResponse({required super.statusCode, super.msg});

  factory SightingSaveResponse.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    return SightingSaveResponse(statusCode: json['statusCode'], msg: msg);
  }
}