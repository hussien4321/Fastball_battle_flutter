class BGM{

  int _id;
  String _src;
  String _name;

  int get id => _id;
  String get src => _src;
  String get name => _name;

  BGM.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      _src = json['src'],
      _name = json['name'];

}