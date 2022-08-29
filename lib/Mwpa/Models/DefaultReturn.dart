
class DefaultReturn {
  final int statusCode;
  final String? msg;

  const DefaultReturn({required this.statusCode, this.msg});

  factory DefaultReturn.fromJson(Map<String, dynamic> json) {
    String? msg;

    if (json.containsKey('msg')) {
      msg = json['msg'];
    }

    return DefaultReturn(
      statusCode: json['statusCode'],
      msg: msg
    );
  }
}