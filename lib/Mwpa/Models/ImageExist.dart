
class ImageExist {
  final String unid;
  final String filename;
  final String size;

  const ImageExist({required this.unid, required this.filename, required this.size});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['unid'] = unid;
    data['filename'] = filename;
    data['size'] = size;

    return data;
  }
}