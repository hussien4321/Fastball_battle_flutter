import './action.dart';

class Character{

  int _id;
  String _name;
  int _unlockThreshold;
  String _hurtSrc;
  String _deathSrc;
  Action _idleAction;
  Action _swingAction;
  Action _hurtAction;
  Action _deathAction;


  int get id => _id;
  String get name => _name;
  int get unlockThreshold => _unlockThreshold;
  String get hurtSrc => _hurtSrc;
  String get deathSrc => _deathSrc;
  Action get idleAction => _idleAction;
  Action get swingAction => _swingAction;
  Action get hurtAction => _hurtAction;
  Action get deathAction => _deathAction;

  Character.fromJson(Map<String, dynamic> json)
    : _id = json['id'],
      _name =json['name'],
      _unlockThreshold = json['unlock_threshold'],
      _hurtSrc = json['hurt_src'],
      _deathSrc = json['death_src'],
      _idleAction = Action.fromJson(json['idle_action']),
      _swingAction = Action.fromJson(json['swing_action']),
      _hurtAction = Action.fromJson(json['hurt_action']),
      _deathAction = Action.fromJson(json['death_action']);

}