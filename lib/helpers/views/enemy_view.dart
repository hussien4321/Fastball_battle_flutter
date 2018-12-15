import 'package:flutter/material.dart';
import '../../models/enemy.dart';

class EnemyView extends StatelessWidget {

  Enemy enemy;
  bool selected;
  bool unlocked;
  VoidCallback onClick;

  EnemyView({this.enemy, this.selected, this.unlocked, this.onClick});

  @override
  Widget build(BuildContext context) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Image.asset(
                  enemy.idleAction.srcPrefix + ((enemy.idleAction.startIndex < 10) ? '0'+enemy.idleAction.startIndex.toString() : enemy.idleAction.startIndex.toString()) + '.png',
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 15.0),),
            Expanded(
              flex: 2,
              child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Text('Enemy ${enemy.id}:\n ${enemy.name}', textAlign: TextAlign.center,),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 5.0),),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(unlocked ? 'Unlocked' : 'Locked'),
                    Icon(unlocked ? Icons.lock_open : Icons.lock)
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: unlocked ? RaisedButton(
                child: Text( selected ? 'SELECTED' : 'SELECT'),
                onPressed: selected ? null : onClick,
              ) : Container(
                  padding: EdgeInsets.all(5.0),
                  child: Text('Get ${enemy.unlockThreshold} points to unlock', textAlign: TextAlign.center, style: TextStyle( fontSize: 10.0),),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 25.0),),
          ],
        ), 
    );
  }
}