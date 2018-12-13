import 'package:flutter/material.dart';
import '../../models/stage.dart';

class StageView extends StatelessWidget {

  Stage stage;
  bool selected;
  bool unlocked;
  VoidCallback onClick;

  StageView({this.stage, this.selected, this.unlocked, this.onClick});

  @override
  Widget build(BuildContext context) {
    // return Material(
    //   color: Colors.amberAccent,
    //   borderRadius: BorderRadius.circular(5.0),
    //   child: 
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Image.asset(
                    stage.src,
                  ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 15.0),),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Text('Stage ${stage.id}: ${stage.name}', textAlign: TextAlign.center,),
            ),
            Padding(padding: EdgeInsets.only(bottom: 5.0),),
            Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(unlocked ? 'Unlocked' : 'Locked'),
                  Icon(unlocked ? Icons.lock_open : Icons.lock)
                ],
              ),
            ),
            unlocked ? RaisedButton(
              child: Text( selected ? 'SELECTED' : 'SELECT'),
              onPressed: selected ? null : onClick,
            ) : Container(
                padding: EdgeInsets.all(5.0),
                child: Text('Get ${stage.unlockThreshold} points to unlock', textAlign: TextAlign.center, style: TextStyle( fontSize: 10.0),),
            ),
            Padding(padding: EdgeInsets.only(bottom: 25.0),),
          ],
        ), 
      //),
    );
  }
}