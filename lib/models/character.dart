import './action.dart';
import './unlock.dart';

class Character{

  int _id;
  String _name;
  Unlock _unlock;
  Action _idleAction;
  Action _swingAction;
  Action _hurtAction;
  Action _deathAction;


  int get id => _id;
  String get name => _name;
  Unlock get unlock => _unlock;
  Action get idleAction => _idleAction;
  Action get swingAction => _swingAction;
  Action get hurtAction => _hurtAction;
  Action get deathAction => _deathAction;

  Character.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      _name =json['name'],
      _unlock = Unlock.fromJson(json['unlock']),
      _idleAction = Action.fromJson(json['idle_action']),
      _swingAction = Action.fromJson(json['swing_action']),
      _hurtAction = Action.fromJson(json['hurt_action']),
      _deathAction = Action.fromJson(json['death_action']);

}