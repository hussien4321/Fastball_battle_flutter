import 'package:flutter/material.dart';
import './sounds_dialog.dart';
import 'package:page_view_indicator/page_view_indicator.dart';

class TutorialDialog extends StatelessWidget {
  
  final pageIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {

    return CustomAlertDialog(
      title: Text('Tutorial'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 160.0,
            width: 300.0,
          child:PageView(
            onPageChanged: (index) => pageIndexNotifier.value = index,
            children: <Widget>[
              _TutorialPageView(
                image: 'assets/other/tutorial1.png',
                text: 'Hi there, welcome to the fastball battle tutorial!\nSwipe right to continue '
              ),
              _TutorialPageView(
                image: 'assets/other/tutorial2.png',
                text: 'The aim of the game is to hit as many balls thrown at you as possible, each time you hit a ball back you get a point!'
              ),
              _TutorialPageView(
                image: 'assets/other/tutorial3.png',
                text: "To hit the ball, hold on the screen and let go as soon as the enemy throws it (you need to be VERY QUICK!)"
              ),
              _TutorialPageView(
                image: 'assets/other/tutorial4.png',
                text: "When you are hit 3 times it's game over.\nNew high scores will unlock new characters, enemies and stages!"
              ),
            ],
          ), 
          ),
          Container(
            child: PageViewIndicator(
              indicatorPadding: EdgeInsets.all(5.0),
              pageIndexNotifier: pageIndexNotifier,
              length: 4,
              normalBuilder: (animationController) => Circle(
                    size: 6.0,
                    color: Colors.black,
                  ),
              highlightedBuilder: (animationController) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: animationController,
                  curve: Curves.ease,
                ),
                child: Circle(
                  size: 8.0,
                  color: Colors.redAccent,
                ),
              ),
            )
          ),
          RaisedButton(
            padding: EdgeInsets.all(0.0),
            child: Text('Close', 
              style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 0.8),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}




class _TutorialPageView extends StatelessWidget {
  
  String image, text;

  _TutorialPageView({this.image, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Image.asset(
              image
            )
          ),
          Container(
            padding: EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
            width: 300.0,
            child: Text(
              text,
              style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 0.6, color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}