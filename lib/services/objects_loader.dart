import 'dart:async';
import 'dart:convert';
import '../models/character.dart';
import '../models/enemy.dart';
import '../models/action.dart';
import '../models/stage.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as UI;
import 'dart:async';
import 'dart:typed_data';


enum AVATAR_TYPE {
  Character, Enemy
}

enum CHAR_ACTION_TYPE {
  IDLE, SWING, HURT, DEATH
}
enum ENEMY_ACTION_TYPE {
  IDLE, THROW, HURT
}

class ObjectsLoader {
  
  final String _filePath = 'assets/data/objects_data.json';

  static final String COIN_SRC = 'assets/other/coin.png';

  static BuildContext _context;

  List<Character> _characters; 
  List<Enemy> _enemies; 
  List<Stage> _stages;
  
  List<Character> get characters => _characters;
  List<Enemy> get enemies => _enemies;
  List<Stage> get stages => _stages; 


  static final ObjectsLoader _singleton  = new ObjectsLoader._internal();

  factory ObjectsLoader(BuildContext context) {
    _context = context;
    return _singleton;
  }

  ObjectsLoader._internal() {
    reInitiliaze();
  }

  reInitiliaze() async {
    if(_stages == null){
      print('Initializing Objects Loader...');
      String data = await DefaultAssetBundle.of(_context).loadString(_filePath);
      final jsonResult = json.decode(data);

      List<dynamic> temp1 = jsonResult['characters'];
      _characters = temp1.map((result) => Character.fromJson(result)).toList();
      List<dynamic> temp2 = jsonResult['enemies'];
      _enemies = temp2.map((result) => Enemy.fromJson(result)).toList();
      List<dynamic> temp3 = jsonResult['stages'];
      _stages = temp3.map((result) => Stage.fromJson(result)).toList();
    }
  }

  Action _loadCharAction(Character char, CHAR_ACTION_TYPE actionType){
    switch (actionType) {
      case CHAR_ACTION_TYPE.IDLE:
        return char.idleAction;
      case CHAR_ACTION_TYPE.SWING:
        return char.swingAction;
      case CHAR_ACTION_TYPE.HURT:
        return char.hurtAction;
      case CHAR_ACTION_TYPE.DEATH:
        return char.deathAction;
      default:
        return null;
    }
  }

  Character getChar(int id) {
    return _characters.where((char)=> char.id==id).toList()[0];
  }

  Stage getStage(int id) {
    return _stages.where((stage)=> stage.id==id).toList()[0];
  }

  Enemy getEnemy(int id) {
    return _enemies.where((enemy)=> enemy.id==id).toList()[0];
  }

  bool checkNewChars(int newHighScore, int lastScore){
    return _characters.any((char) {
      return newHighScore >= char.unlockThreshold && lastScore < char.unlockThreshold;
    });
  }

  bool checkNewEnemies(int newHighScore, int lastScore){
    return _enemies.any((enemy) {
      return newHighScore >= enemy.unlockThreshold && lastScore < enemy.unlockThreshold;
    });
  }

  bool checkNewStages(int newHighScore, int lastScore){
    return _stages.any((stage) {
      return newHighScore >= stage.unlockThreshold && lastScore < stage.unlockThreshold;
    });
  }


  Future<List<UI.Image>> loadCharImages(int id, CHAR_ACTION_TYPE actionType, BuildContext context) async {
    List<UI.Image> imagesList = [];

    Character currChar = _characters.where((char)=> char.id==id).toList()[0]; 
    
    Action currAction = _loadCharAction(currChar, actionType);
    
    int start = currAction.startIndex;
    int count = currAction.imageCount;
    String prefix = currAction.srcPrefix;

    for(int i=(count+start-1) ; i >= start; i--){
      String num = i<10 ? '0$i':'$i';
      UI.Image temp =  await loadImage("$prefix$num.png", context);
      imagesList.add(temp);
    }
    
    return imagesList;
  }


  Action _loadEnemyAction(Enemy enemy, ENEMY_ACTION_TYPE actionType){
    switch (actionType) {
      case ENEMY_ACTION_TYPE.IDLE:
        return enemy.idleAction;
      case ENEMY_ACTION_TYPE.THROW:
        return enemy.throwAction;
      case ENEMY_ACTION_TYPE.HURT:
        return enemy.hurtAction;
      default:
        return null;
    }
  }

  Future<List<UI.Image>> loadEnemyImages(int id, ENEMY_ACTION_TYPE actionType, BuildContext context) async {
    List<UI.Image> imagesList = [];

    Enemy currEnemy = _enemies.where((enemy)=> enemy.id==id).toList()[0]; 
    
    Action currAction = _loadEnemyAction(currEnemy, actionType);
    
    int start = currAction.startIndex;
    int count = currAction.imageCount;
    String prefix = currAction.srcPrefix;

    for(int i=(count+start-1) ; i >= start; i--){
      String num = i<10 ? '0$i':'$i';
      UI.Image temp =  await loadImage("$prefix$num.png", context);
      imagesList.add(temp);
    }
    
    return imagesList;
  }

  Future<UI.Image> loadImage(String link, BuildContext context) async {

    ByteData bd = await DefaultAssetBundle.of(context).load(link);//.then( (bd) {
    Uint8List lst = new Uint8List.view(bd.buffer);
    UI.Codec codec = await UI.instantiateImageCodec(lst);//.then( (codec) {
    UI.FrameInfo frameInfo = await codec.getNextFrame();//.then(
    return frameInfo.image;
  }

}