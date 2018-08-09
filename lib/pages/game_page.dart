import 'package:flutter/material.dart';
import 'dart:math';
import '../animations/game_painter.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin{


  Animation<int> machineAnimation;
  AnimationController  machineAnimationController;

  static final int MACHINE_FIXED_DELAY = 1500; //the minimum ms time that the machine takes to send a new obstacle
  static final int MACHINE_OFFSET_DELAY = 1500; //the additional ms time added to the machine fixed delay to prevent predictability

  Animation<int> obstacleAnimation;
  AnimationController  obstacleAnimationController;

  static final int OBSTACLE_SPEED = 300; //ms time for obstacle to be first to passing by user 

  AnimationController  inputAnimationController;

  static final int TIME_INVALID_AFTER_HIT = 500; //ms time disabled after clicking hit
  bool canInput;

  int currentScore;
  int strikes;

  bool gameInProgress;
  
  void initState() {
    currentScore = 0;
    strikes = 0;
    canInput = true;
    gameInProgress = false;

    machineAnimationController = new AnimationController(duration: new Duration(), vsync: this);
    obstacleAnimationController = new AnimationController(duration: new Duration(milliseconds: OBSTACLE_SPEED), vsync: this);    inputAnimationController = new AnimationController(duration: new Duration(milliseconds: TIME_INVALID_AFTER_HIT), vsync: this);

    machineAnimation = IntTween(
      begin: 0,
      end: 0
    ).animate(machineAnimationController);
    obstacleAnimation = IntTween(
      begin: OBSTACLE_SPEED,
      end: 0
    ).animate(obstacleAnimationController);

    machineAnimationController.addStatusListener((status){
      if(status == AnimationStatus.completed){
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
        int newStrikes = strikes + 1;
        setState(() {
          strikes = newStrikes;
        });
        if(newStrikes < 3){   
          startMachine();
        }else{
          setState(() => gameInProgress = false);
        }
      }
    });
    obstacleAnimationController.addListener(() {
      setState(() {
      });
    });
    
    inputAnimationController.addStatusListener((status){
      if(status == AnimationStatus.completed){
        setState(() => canInput = true);
      }
    });

    super.initState();
  }

  VoidCallback lineUpPitch = (){
    print('HIMME');

  };
  
  @override
  void dispose() {
    machineAnimationController.dispose();
    obstacleAnimationController.dispose();
    inputAnimationController.dispose();
    super.dispose();
  }

  void startMachine(){
    setState(() => gameInProgress = true);
    if(strikes >= 3){
      setState(() {
        strikes = 0;
        currentScore = 0;  
      });
    }
    int rand = MACHINE_FIXED_DELAY + Random().nextInt(MACHINE_OFFSET_DELAY);
    
    machineAnimationController.duration = Duration(milliseconds: rand);
    
    machineAnimation = IntTween(
      begin: rand,
      end: 0
    ).animate(machineAnimationController);

    machineAnimationController.reset();
    machineAnimationController.forward();
  }


  void swing() {
    
    if(canInput){
      if(obstacleAnimation.value != 0 && obstacleAnimation.value != OBSTACLE_SPEED){
        int newScore = currentScore + 1;
        setState(() => currentScore = newScore);
        obstacleAnimationController.stop();
        obstacleAnimationController.reset();
        startMachine();
      }
      setState(() => canInput = false);
      inputAnimationController.reset();
      inputAnimationController.forward();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
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
          Text(
            'Next Pitch in : ${machineAnimation.value} ms',
            style: TextStyle(fontSize: 25.0),
          ),
          Text(
            'Ball speed: ${obstacleAnimation.value} ms',
            style: TextStyle(fontSize: 25.0),
          ),
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
                      onPressed: canInput ? () => swing() : null,
                      child: Text('Swing')
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomPaint(size: Size(1000.0,1000.0), painter: GamePainter(obstacleAnimation.value == 0 ? 0.0 : obstacleAnimation.value / OBSTACLE_SPEED)),
          ),
        ],
      ),
    );
  }
}