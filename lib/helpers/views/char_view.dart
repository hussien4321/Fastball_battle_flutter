import 'package:flutter/material.dart';
import '../../models/character.dart';

class CharView extends StatelessWidget {

  Character char;
  bool selected;
  bool unlocked;
  VoidCallback onClick;

  CharView({this.char, this.selected, this.unlocked, this.onClick});

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
                  char.idleAction.srcPrefix + ((char.idleAction.startIndex < 10) ? '0'+char.idleAction.startIndex.toString() : char.idleAction.startIndex.toString()) + '.png',
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 15.0),),
            Expanded(
              flex: 2,
              child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Text('Character ${char.id}:\n ${char.name}', textAlign: TextAlign.center,),
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
                  child: Text('Get ${char.unlockThreshold} points to unlock', textAlign: TextAlign.center, style: TextStyle( fontSize: 10.0),),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 25.0),),
          ],
        ), 
    );
  }
}