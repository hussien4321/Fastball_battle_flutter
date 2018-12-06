import 'package:flutter/material.dart';
import 'dart:math';
import '../animations/game_painter.dart';
import 'dart:ui' as UI;
import 'dart:async';
import 'dart:typed_data';

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

  static final int OBSTACLE_DEATH_DURATION = 600;//(OBSTACLE_DURATION*0.5).toInt(); //ms time for obstacle to be first to passing by user 
  
  OBSTACLE_STATUS obstacle_status;
  
  bool obstacleIsHit;

  Animation<int> inputAnimation;
  AnimationController  inputAnimationController;

  static final int TIME_INVALID_AFTER_HIT = 500; //ms time disabled after clicking hit
  bool canInput;

  int currentScore;
  int strikes;

  bool gameInProgress;

  bool loading;
  UI.Image ballImage;
  List<UI.Image> enemyIdleImages;
  List<UI.Image> enemyInputImages;
  List<UI.Image> charIdleImages;
  List<UI.Image> charInputImages;

  void initState() {

    loading = true;
    enemyIdleImages = [];
    enemyInputImages = [];
    charIdleImages = [];
    charInputImages = [];
    newGameState();

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


    loadImages();
    super.initState();
  }

  void loadImages() async{
    ballImage =  await loadImage("assets/balls/rock.png");

    for(int i=18; i > 0; i--){
      String num = i<10 ? '0$i':'$i';
      UI.Image temp =  await loadImage("assets/enemy_animations/enemy_01/enemy_idle/idle_$num.png");
      enemyIdleImages.add(temp);
    }
    for(int i=11; i >= 3; i--){
      String num = i<10 ? '0$i':'$i';
      UI.Image temp =  await loadImage("assets/enemy_animations/enemy_01/enemy_throw/Throwing_0$num.png");
      enemyInputImages.add(temp);
    }
    
    for(int i=23; i >= 0; i--){
      String num = i<10 ? '0$i':'$i';
      UI.Image temp =  await loadImage("assets/player_animations/player_01/player_idle/Idle_0$num.png");
      charIdleImages.add(temp);
    }
    for(int i=9; i  > 0; i--){
      String num = i<10 ? '0$i':'$i';
      UI.Image temp =  await loadImage("assets/player_animations/player_01/player_swing/swing_$num.png");
      charInputImages.add(temp);
    }
    
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
    return Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/backgrounds/stadium.jpg", bundle: DefaultAssetBundle.of(context)),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: loading? Text('Loading...') :
              Container(
                  child: CustomPaint(size: Size(1000.0,1000.0), painter: 
                    GamePainter(
                      context, 
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
                      charIdleImages, 
                      charInputImages,
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
                'Score: '+currentScore.toString(),
                style: TextStyle(fontSize: 30.0),
              ),
              Text(
                'Strikes: '+strikes.toString(),
                style: TextStyle(fontSize: 30.0),
              ),
              Container(
                padding: EdgeInsets.only(top: 30.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: gameInProgress ? Container() :RaisedButton(
                          onPressed: !gameInProgress ? (()=> startMachine()) : null,
                          child: Text(!gameInProgress ? strikes < 3 ? 'Start game' : 'Play again' :  'Playing'),
                          color: Colors.orange[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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