class Stage{

  int _id;
  String _name;
  String _src;
  String _bgm;
  int _unlockThreshold;

  int get id => _id;
  String get name => _name;
  String get src => _src;
  String get bgm => _bgm;
  int get unlockThreshold => _unlockThreshold;

  Stage.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      _name =json['name'],
      _src =json['src'],
      _bgm =json['bgm'],
      _unlockThreshold = json['unlock_threshold'];

  @override
  String toString() {
      // TODO: implement toString
      return "Stage w/ id:$id, name:$name, src:$src, bgm:$bgm, threshold:$unlockThreshold";
    }
}