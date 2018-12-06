import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/enemy.dart';
import '../models/stage.dart';



class ObjectsLoader {
  
  final String _filePath = 'assets/data/objects_data.json';

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