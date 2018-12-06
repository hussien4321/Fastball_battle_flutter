import './action.dart';
import './unlock.dart';

class Enemy{

  int _id;
  String _name;
  Unlock _unlock;
  String _weaponSrc;
  Action _idleAction;
  Action _throwAction;
  Action _hurtAction;


  int get id => _id;
  String get name => _name;
  Unlock get unlock => _unlock;
  String get weaponSrc => _weaponSrc;
  Action get idleAction => _idleAction;
  Action get throwAction => _throwAction;
  Action get hurtAction => _hurtAction;
  
  Enemy.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      _name =json['name'],
      _unlock = Unlock.fromJson(json['unlock']),
      _weaponSrc = json['weapon_src'],
      _idleAction = Action.fromJson(json['idle_action']),
      _throwAction = Action.fromJson(json['throw_action']),
      _hurtAction = Action.fromJson(json['hurt_action']);  

}