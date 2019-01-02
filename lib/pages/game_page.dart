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
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_admob/firebase_admob.dart';
import '../services/admob_tools.dart';

class GamePage extends StatefulWidget {

  BuildContext parentContext;
  AudioPlayer bgmController;
  bool isMusicOn;
  AudioCache tonesPlayer;
  bool isTonesOn;
  bool allCharsUnlocked;

  GamePage(this.parentContext, this.bgmController, this.isMusicOn, this.tonesPlayer, this.isTonesOn, this.allCharsUnlocked);

  @override
  _GamePageState createState() => _GamePageState();
}

enum OBSTACLE_STATUS{
  OFFSCREEN,
  ALIVE,
  DEATH,
}
class _GamePageState extends State<GamePage> with TickerProviderStateMixin, WidgetsBindingObserver {

  InterstitialAd myInterstitial;
  bool waitingForAds = false;

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

  static final int OBSTACLE_DEATH_DURATION = 1000; //ms time for obstacle to be first to passing by user 
  
  OBSTACLE_STATUS obstacle_status;
  
  bool obstacleIsHit;

  Animation<int> inputAnimation;
  AnimationController  inputAnimationController;

  static final int TIME_INVALID_AFTER_HIT = 500; //ms time disabled after clicking hit

  
  AnimationController  flashingTextAnimationController;

  static final int FLASHING_TEXT_DURATION = 2000; //the time for one appear and disappear of text 

  AnimationController  gameStartAnimationController;

  static final int GAME_START_TEXT_DURATION = 3000; //the minimum time the user should be shown the message on the load screen before game starts 

  AnimationController  waitForAdsController;

  static final int WAIT_FOR_ADS_DURATION = 1500; //the minimum time the user should be prevented from starting a new game, so the ad can load appropriately 

  bool canInput;


  bool newHighScore;

  bool adsPaidStatus = false;

  int highScore;
  int currentScore;
  int strikes;
  int nextUnlockable;

  bool gameInProgress;

  bool loading, forcedLoading;


  Stage stage;
  Character char;
  Enemy enemy;

  UI.Image ballImage;
  UI.Image ballRevImage;
  
  List<UI.Image> collisionImages;

  List<UI.Image> enemyIdleImages;
  List<UI.Image> enemyInputImages;
  List<UI.Image> enemyHurtImages;
  
  List<UI.Image> charIdleImages;
  List<UI.Image> charInputImages;
  List<UI.Image> charHurtImages;
  List<UI.Image> charDeathImages;

  AudioPlayer swingController = new AudioPlayer();


  bool playedEnemyHurtSound = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state.index == 0 ){
      if(widget.isMusicOn){
        widget.bgmController.resume();
      }
    } else {
      if(widget.isMusicOn){
        widget.bgmController.pause();
      }
    }
  }

  void initState() {

    loading = true;
    forcedLoading = true;
    objectsLoader = new ObjectsLoader(context);
    stats = StatsLoader();

    myInterstitial = createInterstitialAd()..load();

    collisionImages = [];
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
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }


  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: AdmobTools.interstitialAdUnitId,
      targetingInfo: AdmobTools.targetingInfo,
      listener: (MobileAdEvent event) {
        if(event == MobileAdEvent.closed){
          myInterstitial = createInterstitialAd()..load();
        }
      },
    );
  }

  void initControllers(){

      machineAnimationController = new AnimationController(duration: new Duration(), vsync: this);
      obstacleAnimationController = new AnimationController(duration: new Duration(milliseconds: OBSTACLE_DURATION), vsync: this);
      obstacleDeathAnimationController = new AnimationController(duration: new Duration(milliseconds: OBSTACLE_DEATH_DURATION), vsync: this);
      inputAnimationController = new AnimationController(duration: new Duration(milliseconds: TIME_INVALID_AFTER_HIT), vsync: this);
      flashingTextAnimationController = new AnimationController(duration: new Duration(milliseconds: FLASHING_TEXT_DURATION), vsync: this);
      gameStartAnimationController = new AnimationController(duration: new Duration(milliseconds: GAME_START_TEXT_DURATION), vsync: this);
      waitForAdsController = new AnimationController(duration: new Duration(milliseconds: WAIT_FOR_ADS_DURATION), vsync: this);

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
          if(widget.isTonesOn){
            widget.tonesPlayer.play(objectsLoader.getThrowSound(shootBullets: enemy.shootsBullets));
          }
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
            if(widget.isTonesOn){
              widget.tonesPlayer.play(objectsLoader.getHitBackSound());
            }
            int newScore = currentScore + 1;
            if(newScore > highScore){
              if(widget.isTonesOn){
                widget.tonesPlayer.play(ObjectsLoader.NEW_HIGH_SCORE_TONE);
              }
              nextUnlockable = objectsLoader.calculateNextUnlockable(highScore, widget.allCharsUnlocked);
              newHighScore = true;
            }
            setState(() {
              currentScore = newScore;
            });
          }
          else{
            swingController.stop();
            int newStrikes = strikes + 1;
            if(newStrikes == 3){
              if(widget.isTonesOn){
                widget.tonesPlayer.play(char.deathSrc);
              }
            }
            else{ 
              if(widget.isTonesOn){
                widget.tonesPlayer.play(char.hurtSrc);
              }
            }
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
              playedEnemyHurtSound = false;
            });          
          }
          if(!isGameOver()){
            startMachine();
          } else{
            if(widget.isMusicOn){
              widget.bgmController.pause();
            }
            if(currentScore > highScore){
              if(widget.isMusicOn){
                widget.tonesPlayer.play(ObjectsLoader.NEW_HIGH_SCORE_JINGLE);
              }
              stats.updatePreference(StatsLoader.HIGH_SCORE, currentScore);           
              highScore = currentScore; 
            }else{
              if(widget.isMusicOn){
                widget.tonesPlayer.play(ObjectsLoader.LOSE_GAME_JINGLE);
              }
            }
            setState(() => gameInProgress = false);
            if(!adsPaidStatus){
              setState(() {
                waitingForAds = true;
              });
              myInterstitial..show(
                anchorType: AnchorType.bottom,
                anchorOffset: 0.0,
              );
              waitForAdsController.forward();
            }
          }
          obstacle_status = OBSTACLE_STATUS.OFFSCREEN;
        }
      });

      obstacleDeathAnimationController.addListener(() {
        if(obstacleDeathAnimation.value/OBSTACLE_DEATH_DURATION < 0.7 && !playedEnemyHurtSound && obstacleIsHit){
          if(widget.isTonesOn){
            widget.tonesPlayer.play(enemy.hurtSrc);
          }
          playedEnemyHurtSound = true;
        }
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

      flashingTextAnimationController.addListener(() {
        setState(() {
        });
      });
  
      flashingTextAnimationController.repeat();


      gameStartAnimationController.addStatusListener((status){
        if(status == AnimationStatus.completed){
          setState(() => forcedLoading = false);
          startMachine();
        }
      });

      gameStartAnimationController.forward();
      
      waitForAdsController.addStatusListener((status){
        if(status == AnimationStatus.completed){
          setState(() => waitingForAds = false);
          waitForAdsController.reset();
        }
      });
  }


  void loadImages() async{

    adsPaidStatus = await stats.getPreference(StatsLoader.ADS_PAID_STATUS);

    int stageId = await stats.getPreference(StatsLoader.CURRENT_STAGE);
    
    setState(() {
      stage = objectsLoader.getStage(stageId);
    });
    
    highScore = await stats.getPreference(StatsLoader.HIGH_SCORE);
    int charId = await stats.getPreference(StatsLoader.CURRENT_CHARACTER);
    int enemyId = await stats.getPreference(StatsLoader.CURRENT_ENEMY);

    nextUnlockable = objectsLoader.calculateNextUnlockable(highScore, widget.allCharsUnlocked);

    char = objectsLoader.getChar(charId);
    enemy = objectsLoader.getEnemy(enemyId);

    ballImage =  await objectsLoader.loadImage(enemy.weaponSrc, context);

    if(enemy.shootsBullets){
      String revSrc = enemy.weaponSrc.substring(0, enemy.weaponSrc.length-4)+'_rev.png';
      ballRevImage = await objectsLoader.loadImage(revSrc, context); 
    }

    collisionImages = await objectsLoader.loadCollisionImages(context);

    enemyIdleImages = await objectsLoader.loadEnemyImages(enemy.id, ENEMY_ACTION_TYPE.IDLE, context);
    enemyInputImages = await objectsLoader.loadEnemyImages(enemy.id, ENEMY_ACTION_TYPE.THROW, context);
    enemyHurtImages = await objectsLoader.loadEnemyImages(enemy.id, ENEMY_ACTION_TYPE.HURT, context);
    
    charIdleImages = await objectsLoader.loadCharImages(char.id, CHAR_ACTION_TYPE.IDLE, context);
    charInputImages = await objectsLoader.loadCharImages(char.id, CHAR_ACTION_TYPE.SWING, context);
    charHurtImages = await objectsLoader.loadCharImages(char.id, CHAR_ACTION_TYPE.HURT, context);
    charDeathImages = await objectsLoader.loadCharImages(char.id, CHAR_ACTION_TYPE.DEATH, context);
    
    setState(() {
      loading = false;
    });
    
  }

  Future<UI.Image> loadImage(String link) async {

    ByteData bd = await DefaultAssetBundle.of(widget.parentContext).load(link);
    Uint8List lst = new Uint8List.view(bd.buffer);
    UI.Codec codec = await UI.instantiateImageCodec(lst);
    UI.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  bool isGameOver() {
    return strikes >= 3;
  }

  @override
  void dispose() {
    if(widget.isTonesOn){
      widget.tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
    }
    machineAnimationController.dispose();
    obstacleAnimationController.dispose();
    obstacleDeathAnimationController.dispose();
    inputAnimationController.dispose();
    flashingTextAnimationController.dispose();
    gameStartAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    myInterstitial?.dispose();
    myInterstitial = null;

    super.dispose();
  }

  newGameState(){
    setState(() {      
      newHighScore = false;
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
      if(widget.isMusicOn){
        widget.bgmController.resume();
      }
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

  void backToMenu(){
    Navigator.of(context).pop();
  }

  void triggerInput() {
    
    if(canInput && gameInProgress){
      if(widget.isTonesOn && obstacle_status != OBSTACLE_STATUS.DEATH){
        widget.tonesPlayer.play(objectsLoader.getSwingSound(), volume: 0.5).then((controller) {
          swingController = controller;
        });
      }
      if(obstacleAnimation.value != 0 && obstacleAnimation.value <= CAN_HIT_OBSTACLE){
        obstacleIsHit = true;
      }
      setState(() => canInput = false);
      inputAnimationController.reset();
      inputAnimationController.forward();
    }

  }

  canShowFlashingText() {
    return flashingTextAnimationController.value < 0.5;
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
      child: (loading || forcedLoading) ? Center(child: Text('Tap screen to swing!')) : Stack(
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
                      ballRevImage,
                      enemy.shootsBullets,
                      collisionImages,
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
              Padding( padding: EdgeInsets.only(top: 20.0)),
              Text(
                newHighScore ? canShowFlashingText() ? 'NEW HIGH SCORE!' : '' : gameInProgress ? '' : (nextUnlockable == 10000000 || widget.allCharsUnlocked ? 'Good game!' : 'Next unlockable at $nextUnlockable points'),
                style: TextStyle(fontSize: 20.0),
              ),
              gameInProgress ? Container() : Container(
                padding: EdgeInsets.all(30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: (()=> backToMenu()),
                      child: Text(
                        'Back to menu',
                        style: Theme.of(context).textTheme.body1,
                      ),
                      color: Colors.orange[300],
                    ),
                    RaisedButton(
                      onPressed: waitingForAds ? null : (()=> startMachine()),
                      child: Text(
                        'Play again',
                        style: Theme.of(context).textTheme.body1,
                      ),
                      color: Colors.orange[300],
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
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.only(top: 30.0, right: 10.0),
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: Colors.orange[100],
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  iconSize: 30.0,
                  color: Colors.black,
                  padding: EdgeInsets.all(0.0),
                ),
              ),
            ),
          )
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