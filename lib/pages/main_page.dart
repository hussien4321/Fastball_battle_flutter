import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import './stage_select_page.dart';
import './enemy_select_page.dart';
import './char_select_page.dart';
import './payments_page.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/stage.dart';
import '../models/enemy.dart';
import '../models/bgm.dart';
import '../models/character.dart';
import '../helpers/views/sounds_dialog.dart';
import '../helpers/views/tutorial_dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import '../services/notifications.dart';

class MainPage extends StatefulWidget {

  BuildContext parentContext;

  MainPage(this.parentContext);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{
  NotificationService notifications = new NotificationService();

  StatsLoader stats;
  ObjectsLoader objectsLoader;
  AudioCache bgmPlayer, tonesPlayer;
  AudioPlayer bgmController = new AudioPlayer();

  Character char;
  Enemy enemy;
  Stage stage;
  BGM bgm;

  bool shareEnabled = false;

  bool isMusicOn, isTonesOn, allCharsUnlocked;

  int highScore;

  int lastScoreStage, lastScoreEnemy, lastScoreChar;
  bool newChars, newEnemies, newStages;

  bool loading = true;

  void initState() {
    super.initState();
    loadData();
  }


  loadData() async {
    stats = new StatsLoader();
    await stats.reInitiliaze();
    objectsLoader = new ObjectsLoader(context);
    await objectsLoader.reInitiliaze();



    await loadChar();
    await loadEnemy();
    await loadStage();
    await loadBGM();

    allCharsUnlocked = await stats.getPreference(StatsLoader.ALL_ITEMS_UNLOCKED_STATUS);
    isMusicOn = await stats.getPreference(StatsLoader.MUSIC_STATUS);
    isTonesOn = await stats.getPreference(StatsLoader.TONES_STATUS);
    
    
    bgmPlayer = new AudioCache();
    tonesPlayer = new AudioCache();

    // TODO: Set up a notification for 1 day with something like, "Can't beat your score of 10, have you given up?" 
    int highScoreValue = await stats.getPreference(StatsLoader.HIGH_SCORE);

    notifications.createReminderNotification(highScoreValue, objectsLoader.calculateNextUnlockable(highScoreValue, allCharsUnlocked));

    newChars = false;
    newEnemies = false;
    newStages = false;
    
        
    lastScoreStage = await stats.getPreference(StatsLoader.STAGE_PAGE_SCORE);
    lastScoreEnemy = await stats.getPreference(StatsLoader.ENEMY_PAGE_SCORE);
    lastScoreChar = await stats.getPreference(StatsLoader.CHAR_PAGE_SCORE);

    newChars = objectsLoader.checkNewChars(highScoreValue, lastScoreChar);
    newEnemies = objectsLoader.checkNewEnemies(highScoreValue, lastScoreEnemy);
    newStages = objectsLoader.checkNewStages(highScoreValue, lastScoreStage);



    setState(() {
      highScore = highScoreValue;
      loading = false; 
    });
  }

  loadChar() async {
    int charId = await stats.getPreference(StatsLoader.CURRENT_CHARACTER);
    setState(() {
      char = objectsLoader.getChar(charId);
    });
  }

  loadEnemy() async {
    int enemyId = await stats.getPreference(StatsLoader.CURRENT_ENEMY);
    setState(() {
      enemy = objectsLoader.getEnemy(enemyId);
    });
  }

  loadStage() async {
    int stageId = await stats.getPreference(StatsLoader.CURRENT_STAGE);
    setState(() {
      stage = objectsLoader.getStage(stageId);
    });
  }
  loadBGM() async {
    int bgmId = await stats.getPreference(StatsLoader.CURRENT_BGM);
    setState(() {
      bgm = objectsLoader.getBGM(bgmId);
    });
  }

  updatePage() async {
    setState(() {
      loading = true;
    });


    //updates the chars/enemies/stages if they have been changed recently
    allCharsUnlocked = await stats.getPreference(StatsLoader.ALL_ITEMS_UNLOCKED_STATUS);

    int newCharId = await stats.getPreference(StatsLoader.CURRENT_CHARACTER);
    if(newCharId != char.id){
      setState(() {
        char = objectsLoader.getChar(newCharId);
      });
    }
    int newEnemyId = await stats.getPreference(StatsLoader.CURRENT_ENEMY);
    print('newEnemyId:$newEnemyId, enemy.id:${enemy.id}');
    if(newEnemyId != enemy.id){
      setState(() {
        enemy = objectsLoader.getEnemy(newEnemyId);
      });
    }
    int newStageId = await stats.getPreference(StatsLoader.CURRENT_STAGE);
    if(newStageId != stage.id){
      setState(() {
        stage = objectsLoader.getStage(newStageId);
      });
    }
    
    //updates the high score if a game was just finished
    int newHighScore = await stats.getPreference(StatsLoader.HIGH_SCORE);
    if(newHighScore > highScore){
      
      notifications.createReminderNotification(newHighScore, objectsLoader.calculateNextUnlockable(newHighScore, allCharsUnlocked));

      setState(() {
        highScore = newHighScore;
      });
    }

    if(!allCharsUnlocked){
      //checking if new chars/enemies/stages have been unlocked and updates that info on the page button
      lastScoreStage = await stats.getPreference(StatsLoader.STAGE_PAGE_SCORE);
      lastScoreEnemy = await stats.getPreference(StatsLoader.ENEMY_PAGE_SCORE);
      lastScoreChar = await stats.getPreference(StatsLoader.CHAR_PAGE_SCORE);

      newChars = objectsLoader.checkNewChars(newHighScore, lastScoreChar);
      newEnemies = objectsLoader.checkNewEnemies(newHighScore, lastScoreEnemy);
      newStages = objectsLoader.checkNewStages(newHighScore, lastScoreStage);
    }

    setState(() {
      loading = false;
    });

  }

  @override
  void dispose() {
    super.dispose();
    bgmController.release();
    bgmPlayer.clearCache();
    tonesPlayer.clearCache();

  }
Future<Null>_showSoundsDialog() async {
  return showDialog(
    context: context,
    builder: (newContext) {
      return SoundsDialog(
        isMusicOn: isMusicOn,
        isTonesOn: isTonesOn,
        currentBGM: bgm.id,
        updateMusicSwitch: (onOff) {
          stats.updatePreference(StatsLoader.MUSIC_STATUS, onOff);
          setState(() {
            isMusicOn = onOff;                                    
          });
          Navigator.of(context).pop();
          _showSoundsDialog();
        },
        updateTonesSwitch: (onOff) {
          stats.updatePreference(StatsLoader.TONES_STATUS, onOff);
          setState(() {
            isTonesOn = onOff;                                    
          });
          Navigator.of(context).pop();
          _showSoundsDialog();
        },
        updateBGM: (newBGMId) {
          stats.updatePreference(StatsLoader.CURRENT_BGM, newBGMId);
          if(newBGMId != bgm.id){
            setState(() {
              bgm = objectsLoader.getBGM(newBGMId);
            });
          }
          Navigator.of(context).pop();
          _showSoundsDialog();
        },
        onSave: () {
          if(isTonesOn){
            tonesPlayer.play(ObjectsLoader.SELECT_TONE);
          }
          Navigator.of(context).pop();
        }
      );
    }
  );
}

Future<Null>_showTutorialDialog() async {
  return showDialog(
    context: context,
    builder: (newContext) {
      return TutorialDialog();
    }
  );
}
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: stage == null ? BoxDecoration(color: Colors.orangeAccent) : BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage(stage.src, bundle: DefaultAssetBundle.of(context)),
          fit: BoxFit.fill,
        ),
        color: Colors.orangeAccent
      ),
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0, right: 5.0, left: 5.0),
      child: loading ? Center(child: Text('LOADING...')): Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[               
              Container(
                child: Row(
                  children: <Widget>[
                    
                    Container(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        color: Colors.orange[100],
                        child: IconButton(
                          icon: Icon(Icons.music_note),
                          onPressed: _showSoundsDialog,
                          iconSize: 30.0,
                          color: Colors.black,
                          padding: EdgeInsets.all(0.0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Fastball Battle',
                          style: TextStyle(fontSize: 30.0),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        color: Colors.orange[100],
                        child: IconButton(
                          icon: Icon(Icons.help),
                          onPressed: _showTutorialDialog,
                          iconSize: 30.0,
                          color: Colors.black,
                          padding: EdgeInsets.all(0.0),
                        ),
                      ),
                    ),
                  ],

                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 30.0),
                child: Row(
                  children: <Widget>[
                    MenuButton('CHANGE CHARACTER', Icons.person, () async {
                      if(isTonesOn){
                        tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
                      }
                      await Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => CharSelectPage(tonesPlayer, isTonesOn)),
                      );
                      updatePage();
                    }, newChars),
                    MenuButton('CHANGE STAGE', Icons.landscape, () async {
                      if(isTonesOn){
                        tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
                      }
                      await Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => StageSelectPage(tonesPlayer, isTonesOn)),
                      );
                      updatePage();
                    }, newStages),
                    MenuButton('PLAY GAME', Icons.gamepad, () async {
                      if(isTonesOn){
                        tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
                      }
                      if(isMusicOn){
                        bgmController = await bgmPlayer.loop(bgm.src, volume: 0.5);
                      }
                      await Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => GamePage(context, bgmController, isMusicOn, tonesPlayer, isTonesOn, allCharsUnlocked)),
                      );
                      if(isMusicOn){
                        bgmController.release();
                      }
                      updatePage();
                    }),
                    MenuButton('BUY BONUSES', Icons.attach_money, () async {
                      if(isTonesOn){
                        tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
                      }
                      Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => PaymentsPage(tonesPlayer, isTonesOn)),
                      );
                    } ),
                    MenuButton('CHANGE ENEMY', Icons.person_outline, () async {
                      if(isTonesOn){
                        tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
                      }
                      await Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => EnemySelectPage(tonesPlayer, isTonesOn)),
                      );
                      updatePage();
                    }, newEnemies),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      '${char.idleAction.srcPrefix}0${char.idleAction.startIndex}.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),
                  Material(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: Colors.orange[100],
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'High Score: '+ (highScore < 0 ? '...' : highScore.toString()),
                              style: TextStyle(fontSize: 20.0),
                            ),                          
                          ),  
                          shareEnabled ? IconButton(
                            icon: Icon(Icons.share),
                            iconSize: 30.0,
                            onPressed: () => print('I got a high score of $highScore'),
                          ) : Container(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      '${enemy.idleAction.srcPrefix}0${enemy.idleAction.startIndex}.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),                     
                ],
              )
            ],
          ),
    );
  }
}