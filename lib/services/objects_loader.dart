import 'dart:async';
import 'dart:convert';
import '../models/character.dart';
import '../models/enemy.dart';
import '../models/action.dart';
import '../models/stage.dart';
import '../models/bgm.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as UI;
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';


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

  final List<String> _throwSounds = [
    "music/throw_sound_effect_01.wav",
    "music/throw_sound_effect_02.wav",
    "music/throw_sound_effect_03.wav",
  ];
  final List<String> _shootSounds = [
    "music/shoot_sound_effect_01.wav",
    "music/shoot_sound_effect_02.wav",
    "music/shoot_sound_effect_03.wav",
    "music/shoot_sound_effect_04.wav",
    "music/shoot_sound_effect_05.wav",
    "music/shoot_sound_effect_06.wav",
  ];
  final List<String> _hitbackSounds = [
    "music/hitback_01_effect.wav",
    "music/hitback_02_effect.wav",
    "music/hitback_03_effect.wav",
    "music/hitback_04_effect.wav",
    "music/hitback_05_effect.wav",
    "music/hitback_06_effect.wav",
    "music/hitback_07_effect.wav",
  ];
  final List<String> _swingSounds = [
    "music/swing_sound_effect_01.wav",
    "music/swing_sound_effect_02.wav",
    "music/swing_sound_effect_03.wav",
    "music/swing_sound_effect_04.wav",
  ];

  static final String CLICK_TONE = "music/click_tone.wav";
  static final String SELECT_TONE = "music/select_tone.wav";
  static final String PAGE_NAV_TONE = "music/page_navigation_effect.wav";
  static final String NEW_HIGH_SCORE_TONE = "music/new_high_score_tone.wav";
  static final String NEW_HIGH_SCORE_JINGLE = "music/new_high_score_post_game_jingle.wav";
  static final String LOSE_GAME_JINGLE = "music/lose_game_jingle.wav";

  static BuildContext _context;

  List<Character> _characters; 
  List<Enemy> _enemies; 
  List<Stage> _stages;
  List<BGM> _bgms;
  
  List<Character> get characters => _characters;
  List<Enemy> get enemies => _enemies;
  List<Stage> get stages => _stages; 
  List<BGM> get bgms => _bgms; 


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
      String data = await DefaultAssetBundle.of(_context).loadString(_filePath);
      final jsonResult = json.decode(data);

      List<dynamic> temp1 = jsonResult['characters'];
      _characters = temp1.map((result) => Character.fromJson(result)).toList();
      
      List<dynamic> temp2 = jsonResult['enemies'];
      _enemies = temp2.map((result) => Enemy.fromJson(result)).toList();
      
      List<dynamic> temp3 = jsonResult['bgms'];
      _bgms = temp3.map((result) => BGM.fromJson(result)).toList();
      
      List<dynamic> temp4 = jsonResult['stages'];
      _stages = temp4.map((result) => Stage.fromJson(result)).toList();
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
  
  BGM getBGM(int id) {
    return _bgms.where((bgm)=> bgm.id==id).toList()[0];
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

  int calculateNextUnlockable(int newHighScore, bool allCharsUnlocked){
    int nextUnlockable = 10000000;
    if(allCharsUnlocked){
      return nextUnlockable;
    }

    _characters.forEach((char) {
      if(char.unlockThreshold > newHighScore && char.unlockThreshold < nextUnlockable){
        nextUnlockable = char.unlockThreshold;
      }
    });
    _enemies.forEach((enemy) {
      if(enemy.unlockThreshold > newHighScore && enemy.unlockThreshold < nextUnlockable){
        nextUnlockable = enemy.unlockThreshold;
      }
    });
    _stages.forEach((stage) {
      if(stage.unlockThreshold > newHighScore && stage.unlockThreshold < nextUnlockable){
        nextUnlockable = stage.unlockThreshold;
      }
    });

    return nextUnlockable;
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

  Future<List<UI.Image>> loadCollisionImages(BuildContext context) async {
    List<UI.Image> imagesList = [];

    for(int i=11 ; i >= 0; i--){
      String num = i<10 ? '0$i':'$i';
      UI.Image temp =  await loadImage("assets/other/collision/Smoke_0$num.png", context);
      imagesList.add(temp);
    }    
    return imagesList;
  }

  String getThrowSound({bool shootBullets = false}){
    
    List<String> options = shootBullets ? _shootSounds : _throwSounds;

    int randIndex = Random().nextInt(options.length);
    
    return options[randIndex];
    
  }

  String getHitBackSound(){
    
    List<String> options = _hitbackSounds;

    int randIndex = Random().nextInt(options.length);
    
    return options[randIndex];
    
  }
  String getSwingSound(){
    
    List<String> options = _swingSounds;

    int randIndex = Random().nextInt(options.length);
    
    return options[randIndex];
    
  }

  Future<UI.Image> loadImage(String link, BuildContext context) async {

    ByteData bd = await DefaultAssetBundle.of(context).load(link);//.then( (bd) {
    Uint8List lst = new Uint8List.view(bd.buffer);
    UI.Codec codec = await UI.instantiateImageCodec(lst);//.then( (codec) {
    UI.FrameInfo frameInfo = await codec.getNextFrame();//.then(
    return frameInfo.image;
  }

}