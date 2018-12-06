

class Action{

  String _srcPrefix;
  int _startIndex;
  int _imageCount;

  String get srcPrefix => _srcPrefix;
  int get startIndex => _startIndex;
  int get imageCount => _imageCount;
  

  Action.fromJson(Map<String, dynamic> json)
    : _srcPrefix = json['src_prefix'],
      _startIndex = json['start_index'],
      _imageCount = json['image_count'];

}