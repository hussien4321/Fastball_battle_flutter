import 'package:flutter/material.dart';
import '../pages/game_page.dart';

class GamePainter extends CustomPainter {

  Paint _paint1;
  Paint _paint2;
  Paint _paint3;

  static double charHeight = 100.0;
  static double charWidth = 50.0;

  OBSTACLE_STATUS obstacleStatus;
  double obstaclePos;
  double obstacleDeathPos;
  bool obstacleIsHit;
  double obstacleSize = 20.0;
  
  GamePainter(double newObstaclePos, double newObstacleDeathPos, bool newObstacleIsHit, OBSTACLE_STATUS newObstacleStatus){
    obstacleStatus = newObstacleStatus;
    obstaclePos = newObstaclePos;
    obstacleDeathPos = newObstacleDeathPos;
    obstacleIsHit = newObstacleIsHit;
    _paint1 = Paint()
      ..color = Colors.red;
    _paint2 = Paint()
      ..color = Colors.blue;
    _paint3 = Paint()
      ..color = Colors.green;
  }

  @override
  void paint(Canvas canvas, Size size){    
    canvas.drawRect(Rect.fromLTWH(size.width*0.1, size.height - charHeight, charWidth, charHeight), _paint2);
    canvas.drawRect(Rect.fromLTWH(size.width*0.9, size.height - charHeight, charWidth, charHeight), _paint1);

    if(obstacleStatus == OBSTACLE_STATUS.ALIVE){
      print("ALAAAIVE");
      double currentPos = ((size.width*0.7) * obstaclePos ) + size.width*0.2;
      canvas.drawCircle(Offset(currentPos, size.height-(charHeight/2)), obstacleSize/2, _paint1);
    }
    if(obstacleStatus == OBSTACLE_STATUS.DEATH){
      print("DEAAATH");
      if(obstacleIsHit){
        double currentDeathXpos = size.width*0.2 + (size.width * (1-obstacleDeathPos));
        double currentDeathYpos = (size.height-(charHeight/2)) -  (size.height * (1-obstacleDeathPos)); 
        canvas.drawCircle(Offset(currentDeathXpos, currentDeathYpos), obstacleSize/2, _paint3);
      }else{
        double currentDeathPos = ((size.width*0.35+obstacleSize) * obstacleDeathPos) - obstacleSize - size.width*0.15;
        canvas.drawCircle(Offset(currentDeathPos, size.height-(charHeight/2)), obstacleSize/2, _paint1);
      }
    }

  }


  @override
    bool shouldRepaint(GamePainter oldDelegate) {
      return oldDelegate.obstacleDeathPos != obstacleDeathPos || oldDelegate.obstacleIsHit != obstacleIsHit || oldDelegate.obstaclePos != obstaclePos || oldDelegate.obstacleStatus != obstacleStatus;
    }
}