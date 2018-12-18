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


  //REMEMBER: Any new attributes to this file means the version MUST be incremented!
  final Map<String, dynamic> _initialPreferences = {
    'v': 1,
    'currentChar' : 1,
    'currentEnemy' : 1,
    'currentStage' : 1,
    'stagePageScore' : 0,
    'enemyPageScore' : 0,
    'charPageScore' : 0,
    'highScore' : 0,
    'adsPaidStatus' : false,
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
      if(_currentPreferences.containsKey('v') || _currentPreferences['v'] < _initialPreferences['v']){
        for(String missingKey in _initialPreferences.keys){
          if(!_currentPreferences.containsKey(missingKey)){
            _currentPreferences[missingKey] = _initialPreferences[missingKey];
            _jsonFile.writeAsStringSync(json.encode(_currentPreferences));
          }
        }
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