import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import './stage_select_page.dart';
import './enemy_select_page.dart';
import './char_select_page.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/stage.dart';
import '../models/enemy.dart';
import '../models/character.dart';

class MainPage extends StatefulWidget {

  BuildContext parentContext;

  MainPage(this.parentContext);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{

  StatsLoader stats;
  ObjectsLoader objectsLoader;

  Character char;
  Enemy enemy;
  Stage stage;

  int highScore;

  int lastScoreStage, lastScoreEnemy, lastScoreChar;
  bool newChars, newEnemies, newStages;

  bool loading = true;

  void initState() {
    super.initState();
    loadData();
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
      enemy = objectsLoader.getEnemy(enemyId);;
    });
  }

  loadStage() async {
    int stageId = await stats.getPreference(StatsLoader.CURRENT_STAGE);
    setState(() {
      stage = objectsLoader.getStage(stageId);;
    });
  }

  loadData() async {
    stats = new StatsLoader();
    await stats.reInitiliaze();
    objectsLoader = new ObjectsLoader(context);
    await objectsLoader.reInitiliaze();

    loadChar();
    loadEnemy();
    loadStage();
    int highScoreValue = await stats.getPreference(StatsLoader.HIGH_SCORE);

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
      this.highScore = highScoreValue;
      loading = false; 
    });
  }

  updatePage() async {
    setState(() {
      loading = true;
    });


    //updates the chars/enemies/stages if they have been changed recently

    int newCharId = await stats.getPreference(StatsLoader.CURRENT_CHARACTER);
    if(newCharId != char.id){
      setState(() {
        char = objectsLoader.getChar(newCharId);
      });
    }
    int newEnemyId = await stats.getPreference(StatsLoader.CURRENT_STAGE);
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
      setState(() {
        highScore = newHighScore;
      });
    }

    //checking if new chars/enemies/stages have been unlocked and updates that info on the page button
    lastScoreStage = await stats.getPreference(StatsLoader.STAGE_PAGE_SCORE);
    lastScoreEnemy = await stats.getPreference(StatsLoader.ENEMY_PAGE_SCORE);
    lastScoreChar = await stats.getPreference(StatsLoader.CHAR_PAGE_SCORE);

    newChars = objectsLoader.checkNewChars(newHighScore, lastScoreChar);
    newEnemies = objectsLoader.checkNewEnemies(newHighScore, lastScoreEnemy);
    newStages = objectsLoader.checkNewStages(newHighScore, lastScoreStage);

    setState(() {
      loading = false;
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: stage == null ? null : BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage(stage.src, bundle: DefaultAssetBundle.of(context)),
          fit: BoxFit.fill,
        ),
      ),
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0, right: 5.0, left: 5.0),
      child: loading ? Center(child: Text('LOADING...')): Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[               
              Container(
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Ninja baseball',
                        style: TextStyle(fontSize: 30.0),
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
                      await Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => CharSelectPage()),
                      );
                      updatePage();
                    }, newChars),
                    MenuButton('CHANGE STAGE', Icons.landscape, () async {
                      await Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => StageSelectPage()),
                      );
                      updatePage();
                    }, newStages),
                    MenuButton('PLAY GAME', Icons.gamepad, () async {
                      await Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => GamePage(context)),
                      );
                      updatePage();
                    }),
                    MenuButton('BUY BONUSES', Icons.attach_money, () => print('clicked')),
                    MenuButton('CHANGE ENEMY', Icons.person_outline, () async {
                      Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => EnemySelectPage()),
                      );
                    }, newEnemies),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container()
                  ),
              Material(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: Colors.orange[100],
                child: Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'High Score: '+ (highScore < 0 ? '...' : highScore.toString()),
                        style: TextStyle(fontSize: 20.0),
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        iconSize: 30.0,
                        onPressed: () => print('I got a high score of $highScore'),
                      )
                    ],
                  ),
                ),
              ),
                  Expanded(
                    child: Container()
                  ),
                ],
              )

            ],
          ),
    );
  }
}