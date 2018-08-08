import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {

  Paint _paint1;
  Paint _paint2;

  static double charHeight = 100.0;
  static double charWidth = 50.0;

  double _obstaclePos;
  double obstacleSize = 20.0;
  
  GamePainter(double obstaclePos){
    _obstaclePos = obstaclePos;
    _paint1 = Paint()
      ..color = Colors.red;
    _paint2 = Paint()
      ..color = Colors.blue;
  }

  @override
  void paint(Canvas canvas, Size size){    
    double currentPos = ((size.width+obstacleSize*2) *_obstaclePos ) - obstacleSize;
    canvas.drawCircle(Offset(currentPos, size.height-(charHeight/2)), obstacleSize/2, _paint1);

    canvas.drawRect(Rect.fromLTWH(10.0 , size.height - charHeight, charWidth, charHeight), _paint2);
  }


  @override
    bool shouldRepaint(CustomPainter oldDelegate) {
      // TODO: implement shouldRepaint
      return false;
    }
}