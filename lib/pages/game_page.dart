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
  static final int CAN_HIT_OBSTACLE = 200; //ms time for obstacle to be first to passing by user 

  Animation<int> obstacleDeathAnimation;
  AnimationController  obstacleDeathAnimationController;

  static final int OBSTACLE_DEATH_DURATION = (OBSTACLE_DURATION*0.5).toInt(); //ms time for obstacle to be first to passing by user 
  
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
  UI.Image charImage1;
  List<UI.Image> charInputImages;

  void initState() {

    loading = true;
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
        print(obstacleIsHit ? "BALL HIT!" : "BALL MISS!");
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
    ballImage =  await loadImage("assets/baseball.png");
    charImage1 =  await loadImage("assets/batter_idle.png");
    UI.Image hit1 =  await loadImage("assets/batter_hit1.png");
    UI.Image hit2 =  await loadImage("assets/batter_hit2.png");
    UI.Image hit3 =  await loadImage("assets/batter_hit3.png");
    UI.Image hit4 =  await loadImage("assets/batter_hit4.png");
    charInputImages.add(hit4);
    charInputImages.add(hit3);
    charInputImages.add(hit2);
    charInputImages.add(hit1);
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
    
    if(canInput){
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
      padding: EdgeInsets.only(top: 40.0, left: 0.0, right: 0.0),
      child: Column(
        children: <Widget>[
          Text(
            'Score: '+currentScore.toString(),
            style: TextStyle(fontSize: 30.0),
          ),
          Text(
            'Strikes: '+strikes.toString(),
            style: TextStyle(fontSize: 30.0),
          ),
          // Text(
          //   'Next Pitch in : ${machineAnimation.value} ms',
          //   style: TextStyle(fontSize: 25.0),
          // ),
          // Text(
          //   'Obstacle : ${obstacleAnimation.value} ms',
          //   style: TextStyle(fontSize: 25.0),
          // ),
          // Text(
          //   'Death : ${obstacleDeathAnimation.value} ms',
          //   style: TextStyle(fontSize: 25.0),
          // ),
          Container(
            padding: EdgeInsets.only(top:30.0, bottom: 30.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      onPressed: !gameInProgress ? (()=> startMachine()) : null,
                      child: Text(!gameInProgress ? strikes < 3 ? 'Start game' : 'Play again' :  'Playing')
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      onPressed: canInput ? () => triggerInput() : null,
                      child: Text('Swing')
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading? Text('Loading...') :
          Expanded(
            // child: GamePainter2(context, obstacleTimeAsPercentage(),obstacleDeathTimeAsPercentage(),obstacleIsHit, obstacle_status),
            child: Container(
              decoration: BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/bg_stadium.png", bundle: DefaultAssetBundle.of(context)),
                  fit: BoxFit.fill,
                ),
                border: new Border(
                  top: BorderSide(color: Colors.grey[800], width: 0.5),
                  right: BorderSide(color: Colors.grey[800], width: 0.5),
                  bottom: BorderSide(color: Colors.grey[800], width: 0.5),
                  left: BorderSide(color: Colors.grey[800], width: 0.5)
                ),
              ),
              child: CustomPaint(size: Size(1000.0,1000.0), painter: 
                GamePainter(
                  context, 
                  obstacleTimeAsPercentage(),
                  obstacleDeathTimeAsPercentage(),
                  inputTimeAsPercentage(),
                  canInput,
                  obstacleIsHit, 
                  obstacle_status, 
                  ballImage, 
                  charImage1, 
                  charInputImages,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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