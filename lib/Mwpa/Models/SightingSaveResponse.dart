import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

class SightingSaveResponse extends DefaultReturn {
  final String? unid;

  SightingSaveResponse({required super.statusCode, super.msg, this.unid});

  factory SightingSaveResponse.fromJson(Map<String, dynamic> json) {
    String? msg;
    String? unid;

    if (json.containsKey('unid')) {
      unid = json['unid'];
    }

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    return SightingSaveResponse(
      statusCode: json['statusCode'],
      msg: msg,
      unid: unid
    );
  }
}