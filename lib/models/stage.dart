import './unlock.dart';

class Stage{

  int _id;
  String _name;
  String _src;
  Unlock _unlock;

  int get id => _id;
  String get name => _name;
  String get src => _src;
  Unlock get unlock => _unlock;

  Stage.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      _name =json['name'],
      _src =json['src'],
      _unlock = Unlock.fromJson(json['unlock']);

  @override
  String toString() {
      // TODO: implement toString
      return "Stage w/ id:$id, name:$name, src:$src";
    }
}