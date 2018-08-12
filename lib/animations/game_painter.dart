import 'package:flutter/material.dart';
import '../pages/game_page.dart';
import 'dart:ui' as UI;
import 'dart:typed_data';

class GamePainter extends CustomPainter {

  Paint _paint1;
  Paint _paint2;
  Paint _paint3;
  UI.Image ballImage;
  UI.Image charImage1;
  List<UI.Image> charInputImages;

  static double charHeight = 100.0;
  static double charWidth = 50.0;

  OBSTACLE_STATUS obstacleStatus;
  double obstaclePos;
  double obstacleDeathPos;
  double inputPos;
  bool obstacleIsHit;
  bool canInput;
  double obstacleSize = 20.0;
  
  GamePainter(BuildContext context, double newObstaclePos, double newObstacleDeathPos,double newInputPos, bool newCanInput, bool newObstacleIsHit, OBSTACLE_STATUS newObstacleStatus, UI.Image newBallImage, UI.Image newCharImage1, List<UI.Image> newCharInputImages){
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
    charImage1 = newCharImage1;
    charInputImages = newCharInputImages;
    
  }

  @override
  void paint(Canvas canvas, Size size){    
    
    int index = (inputPos*charInputImages.length).floor();
    // canvas.drawRect(Rect.fromLTWH(size.width*0.1, size.height - charHeight, charWidth, charHeight), _paint2);
    canvas.drawRect(Rect.fromLTWH(size.width*0.9, size.height - charHeight, charWidth, charHeight), _paint1);
    canvas.drawImage(canInput ? charImage1 : charInputImages[index], Offset(size.width*0.2-100.0, size.height-100), _paint2);


    if(obstacleStatus == OBSTACLE_STATUS.ALIVE){
      print("ALAAAIVE");
      double currentPos = ((size.width*0.7) * obstaclePos ) + size.width*0.2;
      // canvas.drawCircle(Offset(currentPos, size.height-(charHeight/2)), obstacleSize/2, _paint1);
      canvas.drawImage(ballImage, Offset(currentPos, size.height-(charHeight/2)), _paint2);

    }
    if(obstacleStatus == OBSTACLE_STATUS.DEATH){
      print("DEAAATH");
      if(obstacleIsHit){
        double currentDeathXpos = size.width*0.2 + (size.width * (1-obstacleDeathPos));
        double currentDeathYpos = (size.height-(charHeight/2)) -  (size.height * (1-obstacleDeathPos)); 
        // canvas.drawCircle(Offset(currentDeathXpos, currentDeathYpos), obstacleSize/2, _paint3);
        canvas.drawImage(ballImage, Offset(currentDeathXpos, currentDeathYpos), _paint2);

      }else{
        double currentDeathPos = ((size.width*0.35+obstacleSize) * obstacleDeathPos) - obstacleSize - size.width*0.15;
        // canvas.drawCircle(Offset(currentDeathPos, size.height-(charHeight/2)), obstacleSize/2, _paint1);
        canvas.drawImage(ballImage, Offset(currentDeathPos, size.height-(charHeight/2)), _paint2);

      }
    }

  }


  @override
    bool shouldRepaint(GamePainter oldDelegate) {
      return oldDelegate.obstacleDeathPos != obstacleDeathPos || oldDelegate.obstacleIsHit != obstacleIsHit || oldDelegate.obstaclePos != obstaclePos || oldDelegate.obstacleStatus != obstacleStatus || oldDelegate.ballImage != ballImage || oldDelegate.canInput != canInput || oldDelegate.inputPos != inputPos;
    }
}