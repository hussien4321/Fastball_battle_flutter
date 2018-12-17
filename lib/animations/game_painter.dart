import 'package:flutter/material.dart';
import '../pages/game_page.dart';
import 'dart:ui' as UI;
import 'dart:math';
import 'dart:typed_data';

class GamePainter extends CustomPainter {

  Paint _paint1;
  Paint _paint2;
  Paint _paint3;
  UI.Image ballImage;
  UI.Image ballRevImage;
  bool shootsBullets;
  int strikes;
  int enemyIndex;
  List<UI.Image> collisionImages;

  List<UI.Image> enemyIdleImages;
  List<UI.Image> enemyInputImages;
  List<UI.Image> enemyHurtImages;
  int idleIndex;
  List<UI.Image> charIdleImages;
  List<UI.Image> charInputImages;
  List<UI.Image> charHurtImages;
  List<UI.Image> charDeathImages;


  static double charHeight = 100.0;
  static double charWidth = 100.0;
  double obstacleSize = 20.0;
  double collisionSize = 40.0;

  OBSTACLE_STATUS obstacleStatus;
  double machinePos;
  double obstaclePos;
  double obstacleDeathPos;
  double inputPos;
  bool obstacleIsHit;
  bool canInput;
  UI.Image currentImage;
  UI.Image enemyImage;
  UI.Image collisionImage;
  
  GamePainter(BuildContext context, int newStrikes, double newMachinePos, double newObstaclePos, double newObstacleDeathPos,double newInputPos, bool newCanInput, bool newObstacleIsHit, OBSTACLE_STATUS newObstacleStatus, UI.Image newBallImage, UI.Image newBallRevImage, bool newShootsBullets, List<UI.Image> newCollisionImages, List<UI.Image> newEnemyIdleImages, List<UI.Image> newEnemyInputImages, List<UI.Image> newEnemyHurtImages, List<UI.Image> newCharIdleImages, List<UI.Image> newCharInputImages, List<UI.Image> newCharHurtImages, List<UI.Image> newCharDeathImages){
    obstacleStatus = newObstacleStatus;
    machinePos = newMachinePos;
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
    ballRevImage = newBallRevImage;
    shootsBullets = newShootsBullets;

    collisionImages =  newCollisionImages;
    strikes = newStrikes;
    enemyIndex = 0;
    enemyIdleImages = newEnemyIdleImages;
    enemyInputImages = newEnemyInputImages;
    enemyHurtImages = newEnemyHurtImages;
    idleIndex = 0;
    charIdleImages = newCharIdleImages;
    charInputImages = newCharInputImages;
    charHurtImages = newCharHurtImages;
    charDeathImages = newCharDeathImages;
  }

  UI.Image getCharImage(){
    if(obstacleStatus == OBSTACLE_STATUS.DEATH && !obstacleIsHit && strikes < 3 && obstacleDeathPos >= 0.3){
      int hurtIndex = ((obstacleDeathPos-0.3)*10/7*charHurtImages.length*0.99).floor();
      return charHurtImages[hurtIndex];
    }else if(strikes >= 3){
      double newDeathPos = (obstacleDeathPos-0.25)*(4/3);
      if(obstacleDeathPos < 0.25){
        newDeathPos = 0.0;
      }
      int deathIndex = (newDeathPos*charDeathImages.length*0.99).floor();
      return charDeathImages[deathIndex];
    }else if(!canInput && !(obstacleStatus == OBSTACLE_STATUS.DEATH && !obstacleIsHit)){
      int inputIndex = (inputPos*charInputImages.length*0.99).floor();
      return charInputImages[inputIndex];
    }else {
      idleIndex = (charIdleImages.length*(DateTime.now().millisecond/1000)).floor();
      return charIdleImages[idleIndex];
    }
  }

  UI.Image getEnemyImage(){
    if(obstacleStatus == OBSTACLE_STATUS.DEATH && obstacleIsHit && obstacleDeathPos <= 0.7){
      int hurtIndex = (obstacleDeathPos*(10/7)*enemyHurtImages.length*0.99).floor();
      return enemyHurtImages[hurtIndex];
    }else if(obstacleStatus==OBSTACLE_STATUS.ALIVE){
      int throwIndex = (obstaclePos* enemyInputImages.length*0.99).floor();
      return enemyInputImages[throwIndex];
    }else {
      enemyIndex = (enemyIdleImages.length*(DateTime.now().millisecond/1000)).floor();
      return enemyIdleImages[enemyIndex];
    }
  }

  UI.Image getCollisionImage(){
    if(obstacleStatus == OBSTACLE_STATUS.DEATH && obstacleIsHit && obstacleDeathPos <= 0.7){
      //hit enemy
      int collisionIndex = (obstacleDeathPos*(10/7)*collisionImages.length*0.99).floor();
      return collisionImages[collisionIndex];
    }else if(obstacleStatus == OBSTACLE_STATUS.DEATH && !obstacleIsHit && obstacleDeathPos >= 0.3){
      // hit player
      int collisionIndex = ((obstacleDeathPos-0.3)*10/7*collisionImages.length*0.99).floor();
      return collisionImages[collisionIndex];
    }else{
      return null;
    }
  }

  @override
  void paint(Canvas canvas, Size size){    

    currentImage = getCharImage();
    enemyImage = getEnemyImage();
    collisionImage = getCollisionImage();

    canvas.drawImageRect(enemyImage, Rect.fromLTRB(0.0,0.0,enemyImage.width.toDouble(), enemyImage.height.toDouble()), Rect.fromLTRB(size.width*0.8, size.height-charHeight+10,size.width*0.8+charWidth, size.height+10), _paint2);

    canvas.drawImageRect(currentImage, Rect.fromLTRB(0.0,0.0,currentImage.width.toDouble() , currentImage.height.toDouble()), Rect.fromLTRB(size.width*0.2-charWidth, size.height-charHeight+10,size.width*0.2, size.height+10), _paint2);

    double ballY = size.height-(charHeight*2/3);
    if(shootsBullets){
      ballY = size.height-(charHeight*4/10);
    }


    if(obstacleStatus == OBSTACLE_STATUS.ALIVE){
      double currentPos = ((size.width*0.6 + charWidth) * obstaclePos) + (size.width*0.2 - charWidth/2);
      canvas.drawImageRect(ballImage, Rect.fromLTRB(0.0, 0.0, ballImage.width.toDouble(), ballImage.height.toDouble()), Rect.fromLTWH(currentPos, ballY, obstacleSize, obstacleSize), _paint2);

    }
    if(obstacleStatus == OBSTACLE_STATUS.DEATH){
      if(obstacleIsHit && obstacleDeathPos > 0.7){

        double startX = size.width*0.2 - charWidth/2;

        double displacementX = size.width*0.6 + charWidth;
        double powerX = (1-obstacleDeathPos) * (10/3);
        
        double newX = startX + displacementX * powerX;
        canvas.drawImageRect(shootsBullets ? ballRevImage : ballImage, Rect.fromLTRB(0.0, 0.0, ballImage.width.toDouble(), ballImage.height.toDouble()), Rect.fromLTWH(newX, ballY, obstacleSize, obstacleSize), _paint2);
      }
    }

    if(collisionImage != null){

      double placement = (collisionSize-obstacleSize)/2;
      double startX = (!obstacleIsHit ? (size.width*0.2 - charWidth/2) : (size.width * 0.8 + charWidth/2)) - placement;
      ballY = ballY- placement;

      canvas.drawImageRect(collisionImage, Rect.fromLTRB(0.0, 0.0, collisionImage.width.toDouble(), collisionImage.height.toDouble()), Rect.fromLTWH(startX, ballY, collisionSize, collisionSize), _paint2);
    }

  }


  @override
    bool shouldRepaint(GamePainter oldDelegate) {
      return oldDelegate.machinePos != machinePos || oldDelegate.obstacleDeathPos != obstacleDeathPos || oldDelegate.obstacleIsHit != obstacleIsHit || oldDelegate.obstaclePos != obstaclePos || oldDelegate.obstacleStatus != obstacleStatus || oldDelegate.ballImage != ballImage || oldDelegate.canInput != canInput || oldDelegate.inputPos != inputPos || oldDelegate.idleIndex != idleIndex || oldDelegate.enemyIndex != enemyIndex || oldDelegate.strikes != strikes || oldDelegate.currentImage != currentImage || oldDelegate.enemyImage != enemyImage || oldDelegate.collisionImage != collisionImage;
    }
}