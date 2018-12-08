import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {

  String text;
  IconData icon;
  VoidCallback onClick;

  MenuButton(this.text, this.icon, this.onClick);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
      padding: EdgeInsets.all(10.0),
      child: Material(
          borderRadius: BorderRadius.circular(5.0),
        color: Colors.orange[100],
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: SizedBox(
          height: 70.0,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: IconButton(
                  icon: Icon(
                    icon,
                    color: Colors.black,
                  ),
                  onPressed: onClick,
                  iconSize: 30.0,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                    child: Text(
                    this.text,
                    style: TextStyle(fontSize: 10.0, color: Colors.orange[800], fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                ),
            ],
          )
          )
        ), 
      ),
      ),
    );
  }
}