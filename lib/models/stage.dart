class Stage{

  int _id;
  String _name;
  String _src;
  int _unlockThreshold;

  int get id => _id;
  String get name => _name;
  String get src => _src;
  int get unlockThreshold => _unlockThreshold;

  Stage.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      _name =json['name'],
      _src =json['src'],
      _unlockThreshold = json['unlock_threshold'];

  @override
  String toString() {
      // TODO: implement toString
      return "Stage w/ id:$id, name:$name, src:$src, threshold:$unlockThreshold";
    }
}