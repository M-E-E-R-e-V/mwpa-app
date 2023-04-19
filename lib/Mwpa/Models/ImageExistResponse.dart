import 'package:mwpaapp/Mwpa/Models/DefaultReturn.dart';

class ImageExistResponse extends DefaultReturn {
  final bool? isExist;

  ImageExistResponse({required super.statusCode, super.msg, this.isExist});

  factory ImageExistResponse.fromJson(Map<String, dynamic> json) {
    String? msg;
    bool? isExist;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    if (json.containsKey('isExist')) {
      isExist = json['isExist'];
    }

    return ImageExistResponse(
      statusCode: json['statusCode'],
      msg: msg,
      isExist: isExist
    );
  }
}