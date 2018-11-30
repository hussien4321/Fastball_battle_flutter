import 'package:flutter/material.dart';
import '../pages/game_page.dart';
import 'dart:ui' as UI;
import 'dart:typed_data';

class GamePainter extends CustomPainter {

  Paint _paint1;
  Paint _paint2;
  Paint _paint3;
  UI.Image ballImage;
  UI.Image enemyImage;
  List<UI.Image> charIdleImages;
  int idleIndex;
  List<UI.Image> charInputImages;


  static double charHeight = 100.0;
  static double charWidth = 100.0;

  OBSTACLE_STATUS obstacleStatus;
  double obstaclePos;
  double obstacleDeathPos;
  double inputPos;
  bool obstacleIsHit;
  bool canInput;
  double obstacleSize = 20.0;
  
  GamePainter(BuildContext context, double newObstaclePos, double newObstacleDeathPos,double newInputPos, bool newCanInput, bool newObstacleIsHit, OBSTACLE_STATUS newObstacleStatus, UI.Image newBallImage, UI.Image newEnemyImage, List<UI.Image> newCharIdleImages, List<UI.Image> newCharInputImages){
    obstacleStatus = newObstacleStatus;
    obstaclePos = newObstaclePos;
    obstacleDeathPos = newObstacleDeathPos;
    inputPos = newInputPos;
    obstacleIsHit = newObstacleIsHit;
    canInput = newCanInput;
    _paint1 = Paint()
      ..color = Colors.red;
    _paint2 = Paint()
      ..color = Colors.blue;
    _paint3 = Paint()
      ..color = Colors.green;
    ballImage = newBallImage;
    enemyImage = newEnemyImage;
    charIdleImages = newCharIdleImages;
    idleIndex = 0;
    charInputImages = newCharInputImages;
    
  }

  @override
  void paint(Canvas canvas, Size size){    
    idleIndex = (charIdleImages.length*(DateTime.now().millisecond/1000)).floor();
    print("idle index is $idleIndex and time now is ${DateTime.now().millisecond}");
    int inputIndex = (inputPos*charInputImages.length).floor();
    canvas.drawImage(enemyImage, Offset(size.width*0.8, size.height-50), _paint2);
    // canvas.drawImage(canInput ? charIdleImages[idleIndex] : charInputImages[inputIndex], Offset(size.width*0.2-100.0, size.height-100), _paint2);
    canvas.drawImageRect(canInput ? charIdleImages[idleIndex] : charInputImages[inputIndex], Rect.fromLTRB(0.0,0.0,canInput ? charIdleImages[0].width.toDouble() : charInputImages[0].width.toDouble(), canInput ? charIdleImages[0].height.toDouble() : charInputImages[0].height.toDouble()), Rect.fromLTRB(size.width*0.2-charWidth, size.height-charHeight,size.width*0.2, size.height), _paint2);


    if(obstacleStatus == OBSTACLE_STATUS.ALIVE){
      double currentPos = ((size.width*0.6) * obstaclePos ) + size.width*0.2;
      canvas.drawImage(ballImage, Offset(currentPos, size.height-(charHeight/2)), _paint2);

    }
    if(obstacleStatus == OBSTACLE_STATUS.DEATH){
      if(obstacleIsHit){
        double currentDeathXpos = size.width*0.2 + (size.width * (1-obstacleDeathPos));
        double currentDeathYpos = (size.height-(charHeight/2)) -  (size.height * (1-obstacleDeathPos)); 
        canvas.drawImage(ballImage, Offset(currentDeathXpos, currentDeathYpos), _paint2);

      }else{
        double currentDeathPos = ((size.width*0.35+obstacleSize) * obstacleDeathPos) - obstacleSize - size.width*0.15;
        canvas.drawImage(ballImage, Offset(currentDeathPos, size.height-(charHeight/2)), _paint2);

      }
    }
  }


  @override
    bool shouldRepaint(GamePainter oldDelegate) {
      return oldDelegate.obstacleDeathPos != obstacleDeathPos || oldDelegate.obstacleIsHit != obstacleIsHit || oldDelegate.obstaclePos != obstaclePos || oldDelegate.obstacleStatus != obstacleStatus || oldDelegate.ballImage != ballImage || oldDelegate.canInput != canInput || oldDelegate.inputPos != inputPos || oldDelegate.idleIndex != idleIndex;
    }
}