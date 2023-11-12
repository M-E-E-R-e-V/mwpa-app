import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

class SightingSaveResponse extends DefaultReturn {
  final String? unid;
  final bool? canDelete;

  SightingSaveResponse({required super.statusCode, super.msg, this.unid, this.canDelete});

  factory SightingSaveResponse.fromJson(Map<String, dynamic> json) {
    String? msg;
    String? unid;
    bool? canDelete;

    if (json.containsKey('unid')) {
      unid = json['unid'];
    }

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    if (json.containsKey('canDelete')) {
      canDelete = json['canDelete'];
    }

    return SightingSaveResponse(
      statusCode: json['statusCode'],
      msg: msg,
      unid: unid,
      canDelete: canDelete
    );
  }
}