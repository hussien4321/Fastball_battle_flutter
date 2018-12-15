import 'package:flutter/material.dart';
import 'dart:math';
import '../animations/game_painter.dart';
import 'dart:ui' as UI;
import 'dart:async';
import 'dart:typed_data';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import '../models/character.dart';
import '../models/stage.dart';
import '../models/enemy.dart';
import '../helpers/views/menu_button.dart';


class GamePage extends StatefulWidget {

  BuildContext parentContext;

  GamePage(this.parentContext);

  @override
  _GamePageState createState() => _GamePageState();
}

enum OBSTACLE_STATUS{
  OFFSCREEN,
  ALIVE,
  DEATH,
}
class _GamePageState extends State<GamePage> with TickerProviderStateMixin{

  StatsLoader stats;
  ObjectsLoader objectsLoader;

  Animation<int> machineAnimation;
  AnimationController  machineAnimationController;

  static final int MACHINE_FIXED_DELAY = 1500; //the minimum ms time that the machine takes to send a new obstacle
  static final int MACHINE_OFFSET_DELAY = 1500; //the additional ms time added to the machine fixed delay to prevent predictability

  Animation<int> obstacleAnimation;
  AnimationController  obstacleAnimationController;

  static final int OBSTACLE_DURATION = 300; //ms time for obstacle to be first to passing by user 
  static final int CAN_HIT_OBSTACLE = ((OBSTACLE_DURATION*2)/3).floor(); //ms time for obstacle to be first to passing by user 

  Animation<int> obstacleDeathAnimation;
  AnimationController  obstacleDeathAnimationController;

  static final int OBSTACLE_DEATH_DURATION = 600; //ms time for obstacle to be first to passing by user 
  
  OBSTACLE_STATUS obstacle_status;
  
  bool obstacleIsHit;

  Animation<int> inputAnimation;
  AnimationController  inputAnimationController;

  static final int TIME_INVALID_AFTER_HIT = 500; //ms time disabled after clicking hit
  bool canInput;

  int highScore;
  int currentScore;
  int strikes;

  bool gameInProgress;

  bool loading;


  Stage stage;
  Character char;
  Enemy enemy;

  UI.Image ballImage;
  
  List<UI.Image> enemyIdleImages;
  List<UI.Image> enemyInputImages;
  List<UI.Image> enemyHurtImages;
  
  List<UI.Image> charIdleImages;
  List<UI.Image> charInputImages;
  List<UI.Image> charHurtImages;
  List<UI.Image> charDeathImages;

  void initState() {

    loading = true;
    
    objectsLoader = new ObjectsLoader(context);
    stats = StatsLoader();

    enemyIdleImages = [];
    enemyInputImages = [];
    enemyHurtImages = [];
    charIdleImages = [];
    charInputImages = [];
    charHurtImages = [];
    charDeathImages = [];

    newGameState();

    initControllers();
    
    loadImages();
    super.initState();
  }

  void initControllers(){
    
      machineAnimationController = new AnimationController(duration: new Duration(), vsync: this);
      obstacleAnimationController = new AnimationController(duration: new Duration(milliseconds: OBSTACLE_DURATION), vsync: this);
      obstacleDeathAnimationController = new AnimationController(duration: new Duration(milliseconds: OBSTACLE_DEATH_DURATION), vsync: this);
      inputAnimationController = new AnimationController(duration: new Duration(milliseconds: TIME_INVALID_AFTER_HIT), vsync: this);

      machineAnimation = IntTween(
        begin: 0,
        end: 0
      ).animate(machineAnimationController);
      obstacleAnimation = IntTween(
        begin: OBSTACLE_DURATION,
        end: 0
      ).animate(obstacleAnimationController);
      obstacleDeathAnimation = IntTween(
        begin: OBSTACLE_DEATH_DURATION,
        end: 0
      ).animate(obstacleDeathAnimationController);
      inputAnimation = IntTween(
        begin: TIME_INVALID_AFTER_HIT,
        end: 0
      ).animate(inputAnimationController);

      machineAnimationController.addStatusListener((status){
        if(status == AnimationStatus.completed){
          obstacle_status = OBSTACLE_STATUS.ALIVE;
          obstacleAnimationController.reset();
          obstacleAnimationController.forward();
        }
      });
      machineAnimationController.addListener(() {
        setState(() {
        });
      });

      obstacleAnimationController.addStatusListener((status){
        if(status == AnimationStatus.completed){
          if(obstacleIsHit){
            int newScore = currentScore + 1;
            setState(() {
              currentScore = newScore;
            });
          }
          else{  
            int newStrikes = strikes + 1;
            setState(() {
              strikes = newStrikes;
            });
          }
          obstacle_status = OBSTACLE_STATUS.DEATH;
          obstacleDeathAnimationController.reset();
          obstacleDeathAnimationController.forward();
        }
      });
      obstacleAnimationController.addListener(() {
        setState(() {
        });
      });
      
      
      obstacleDeathAnimationController.addStatusListener((status){
        if(status == AnimationStatus.completed){
          if(obstacleIsHit){
            setState(() {
              obstacleIsHit = false;
            });          
          }
          if(!isGameOver()){
            startMachine();
          } else{
            //TODO: ADD 'NEW HIGH SCORE' MESSAGE TO POST GAME SCREEN WHEN NEW HIGH SCORE ACHEIVED
            currentScore = 10;
            if(currentScore > highScore){
              stats.updatePreference(StatsLoader.HIGH_SCORE, currentScore);
            }
            setState(() => gameInProgress = false);
          }
          obstacle_status = OBSTACLE_STATUS.OFFSCREEN;
        }
      });

      obstacleDeathAnimationController.addListener(() {
        setState(() {
        });
      });
      

      inputAnimationController.addStatusListener((status){
        if(status == AnimationStatus.completed){
          setState(() => canInput = true);
        }
      });
      inputAnimationController.addListener(() {
        setState(() {
        });
      });
  }


  void loadImages() async{
    int stageId = await stats.getPreference(StatsLoader.CURRENT_STAGE);
    
    setState(() {
      stage = objectsLoader.getStage(stageId);
    });
    
    highScore = await stats.getPreference(StatsLoader.HIGH_SCORE);
    int charId = await stats.getPreference(StatsLoader.CURRENT_CHARACTER);
    int enemyId = await stats.getPreference(StatsLoader.CURRENT_ENEMY);


    char = objectsLoader.getChar(charId);
    enemy = objectsLoader.getEnemy(enemyId);

    ballImage =  await objectsLoader.loadImage(enemy.weaponSrc, context);

    enemyIdleImages = await objectsLoader.loadEnemyImages(enemy.id, ENEMY_ACTION_TYPE.IDLE, context);
    enemyInputImages = await objectsLoader.loadEnemyImages(enemy.id, ENEMY_ACTION_TYPE.THROW, context);
    enemyHurtImages = await objectsLoader.loadEnemyImages(enemy.id, ENEMY_ACTION_TYPE.HURT, context);
    
    charIdleImages = await objectsLoader.loadCharImages(char.id, CHAR_ACTION_TYPE.IDLE, context);
    charInputImages = await objectsLoader.loadCharImages(char.id, CHAR_ACTION_TYPE.SWING, context);
    charHurtImages = await objectsLoader.loadCharImages(char.id, CHAR_ACTION_TYPE.HURT, context);
    charDeathImages = await objectsLoader.loadCharImages(char.id, CHAR_ACTION_TYPE.DEATH, context);
    
    startMachine();
    setState(() {
      loading = false;
    });
    
  }

  Future<UI.Image> loadImage(String link) async {

    ByteData bd = await DefaultAssetBundle.of(widget.parentContext).load(link);//.then( (bd) {
    Uint8List lst = new Uint8List.view(bd.buffer);
    UI.Codec codec = await UI.instantiateImageCodec(lst);//.then( (codec) {
    UI.FrameInfo frameInfo = await codec.getNextFrame();//.then(
    return frameInfo.image;
  }

  bool isGameOver() {
    return strikes >= 3;
  }

  @override
  void dispose() {
    machineAnimationController.dispose();
    obstacleAnimationController.dispose();
    obstacleDeathAnimationController.dispose();
    inputAnimationController.dispose();
    super.dispose();
  }

  newGameState(){
    setState(() {      
      currentScore = 0;
      strikes = 0;
      canInput = true;
      gameInProgress = false;
      obstacleIsHit = false;
      obstacle_status = OBSTACLE_STATUS.OFFSCREEN;
    });
  }

  void startMachine(){
    if(isGameOver()){
      newGameState();
    }
    setState(() => gameInProgress = true);

    int rand = MACHINE_FIXED_DELAY + Random().nextInt(MACHINE_OFFSET_DELAY);
    machineAnimationController.duration = Duration(milliseconds: rand);
    
    machineAnimation = IntTween(
      begin: rand,
      end: 0
    ).animate(machineAnimationController);

    machineAnimationController.reset();
    machineAnimationController.forward();
  }


  void triggerInput() {
    
    if(canInput && gameInProgress){
      if(obstacleAnimation.value != 0 && obstacleAnimation.value <= CAN_HIT_OBSTACLE){
        obstacleIsHit = true;
      }
      setState(() => canInput = false);
      inputAnimationController.reset();
      inputAnimationController.forward();
    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      decoration: stage ==null ? null : BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage(stage.src, bundle: DefaultAssetBundle.of(context)),
          fit: BoxFit.fill,
        ),
      ),
      child: loading? Center(child: Text('Loading...')) : Stack(
        children: <Widget>[
          SizedBox.expand(
            child: 
              Container(
                  child: CustomPaint(size: Size(1000.0,1000.0), painter: 
                    GamePainter(
                      context, 
                      strikes,
                      machineTimeAsPercentage(),
                      obstacleTimeAsPercentage(),
                      obstacleDeathTimeAsPercentage(),
                      inputTimeAsPercentage(),
                      canInput,
                      obstacleIsHit, 
                      obstacle_status, 
                      ballImage, 
                      enemyIdleImages, 
                      enemyInputImages, 
                      enemyHurtImages, 
                      charIdleImages, 
                      charInputImages, 
                      charHurtImages,
                      charDeathImages
                    ),
                  ),
                ),
          ),
          SizedBox.expand(
            child: Opacity(
              opacity: 0.0,
              child: RaisedButton(
                onPressed: () => triggerInput(),
              ),
            ),
          ),
          Column(
            children: <Widget>[ 
              Padding( padding: EdgeInsets.only(top: 40.0)),
              Text(
                currentScore.toString(),
                style: TextStyle(fontSize: 30.0),
              ),
              // Text(
              //   'Strikes: '+strikes.toString(),
              //   style: TextStyle(fontSize: 30.0),
              // ),
              Container(
                padding: EdgeInsets.only(top: 30.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        width: 100.0,
                        padding: EdgeInsets.all(10.0),
                        child: gameInProgress ? Container() : RaisedButton(
                          onPressed: (()=> startMachine()),
                          child: Text('Play again'),
                          color: Colors.orange[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 30.0, left: 10.0),
            child: Row(
              children: <Widget>[
                Image.asset(
                  strikes < 3 ?'assets/other/heart.png':'assets/other/heart_gray.png' ,
                  width: 32.0,
                  height: 32.0,
                ),
                Image.asset(
                  strikes < 2 ?'assets/other/heart.png':'assets/other/heart_gray.png' ,
                  width: 32.0,
                  height: 32.0,
                ),
                Image.asset(
                  strikes < 1 ?'assets/other/heart.png':'assets/other/heart_gray.png' ,
                  width: 32.0,
                  height: 32.0,
                ),
              ],
            )
          ),
        ],
      ),
      ),
    );
  }
  double machineTimeAsPercentage(){
    return machineAnimation.value == 0 ? 0.0 : machineAnimation.value / machineAnimationController.duration.inMilliseconds;
  }
  double obstacleTimeAsPercentage(){
    return obstacleAnimation.value == 0 ? 0.0 : obstacleAnimation.value / OBSTACLE_DURATION;
  }
  double obstacleDeathTimeAsPercentage(){
    return obstacleDeathAnimation.value == 0 ? 0.0 : (obstacleDeathAnimation.value / OBSTACLE_DEATH_DURATION);
  }
  double inputTimeAsPercentage(){
    return inputAnimation.value == 0 ? 0.0 : (inputAnimation.value == TIME_INVALID_AFTER_HIT ? 0.99 : (inputAnimation.value / TIME_INVALID_AFTER_HIT));
  }
}