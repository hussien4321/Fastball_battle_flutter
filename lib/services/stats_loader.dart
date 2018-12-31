import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';


class StatsLoader {


  static final String CURRENT_CHARACTER = 'currentChar';
  static final String CURRENT_ENEMY = 'currentEnemy';
  static final String CURRENT_STAGE = 'currentStage';
  static final String CHAR_PAGE_SCORE = 'charPageScore';
  static final String ENEMY_PAGE_SCORE = 'enemyPageScore';
  static final String STAGE_PAGE_SCORE = 'stagePageScore';
  static final String HIGH_SCORE = 'highScore';
  static final String ADS_PAID_STATUS = 'adsPaidStatus';
  static final String ALL_ITEMS_UNLOCKED_STATUS = 'allItemsUnlockedStatus';
  static final String VOLUME = 'volume';
  static final String MUSIC_STATUS = 'musicStatus';
  static final String TONES_STATUS = 'tonesStatus';
  static final String CURRENT_BGM = 'currentBGM';
  static final String VERSION = 'v';
  


  //REMEMBER: Any new attributes to this file means the version MUST be incremented!
  final Map<String, dynamic> _initialPreferences = {
    'v': 4,
    'currentChar' : 1,
    'currentEnemy' : 1,
    'currentStage' : 1,
    'stagePageScore' : 0,
    'enemyPageScore' : 0,
    'charPageScore' : 0,
    'highScore' : 0,
    'adsPaidStatus' : false,
    'allItemsUnlockedStatus' : false,
    'musicStatus' : true,
    'tonesStatus' : true,
    'volume' : 0.5,
    'currentBGM' : 1
  };

  Map<String, dynamic> _currentPreferences = {};

  Future<Map<String, dynamic>> get currentPreferences async {
    if(_currentPreferences.length != 0){
      return _currentPreferences;
    }
    await reInitiliaze();
    return _currentPreferences;
  }
  
  final String _fileName = 'user_stats.json';
  static File _jsonFile;
  
  static final StatsLoader _singleton = new StatsLoader._internal();

  factory StatsLoader() {
    return _singleton;
  }

  StatsLoader._internal() {
    reInitiliaze();
  }

  reInitiliaze() async {
    print('Initializing Stats Loader...');
    Directory directory = await getApplicationDocumentsDirectory();
    Directory dir = directory;
    _jsonFile = new File(dir.path +  "/" + _fileName);
    bool fileExists = _jsonFile.existsSync();
    if (fileExists){
      _currentPreferences = json.decode(_jsonFile.readAsStringSync());
      if(!_currentPreferences.containsKey(VERSION) || _currentPreferences[VERSION] < _initialPreferences[VERSION]){
        print('detected missing config! ${!_currentPreferences.containsKey('v')} OR ${_currentPreferences['v'] < _initialPreferences['v']} ${_currentPreferences['v']} < ${_initialPreferences['v']}');
        _currentPreferences[VERSION] = _initialPreferences[VERSION];
        print('updated: ${_currentPreferences['v']} = ${_initialPreferences['v']}');
        for(String missingKey in _initialPreferences.keys){
          if(!_currentPreferences.containsKey(missingKey)){
            print('adding $missingKey to _currentPreferences');
            _currentPreferences[missingKey] = _initialPreferences[missingKey];
          }
        }
        //TODO: Remove any deleted attributes
        _jsonFile.writeAsStringSync(json.encode(_currentPreferences));
      }
    } else {
      _currentPreferences = _initialPreferences;
      _createPreferencesFile(_currentPreferences);
    }
  }

  void _createPreferencesFile(Map<String, dynamic> content) {
    _jsonFile.createSync();
    _jsonFile.writeAsStringSync(json.encode(content));
  }


  void updatePreference(String key, dynamic value) {

    Map<String, dynamic> content = {key: value};
    Map<String, dynamic> jsonFileContent = json.decode(_jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    _currentPreferences = jsonFileContent;
    _jsonFile.writeAsStringSync(json.encode(jsonFileContent));
  }


  //testing feature
  Future<dynamic> getPreference(String key) async {
    var preferences = await currentPreferences;

    return preferences[key];
  }
  
} 