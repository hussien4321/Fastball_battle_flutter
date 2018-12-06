import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';

class MainPage extends StatefulWidget {

  BuildContext parentContext;

  MainPage(this.parentContext);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{

  StatsLoader stats = new StatsLoader();
  int coins = -1;
  int highScore = -1;

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    int coinValue = await stats.getPreference(StatsLoader.COINS);
    int highScoreValue = await stats.getPreference(StatsLoader.HIGH_SCORE);

    setState(() {
      this.coins = coinValue;
      this.highScore = highScoreValue; 
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/backgrounds/stadium.jpg", bundle: DefaultAssetBundle.of(context)),
          fit: BoxFit.fill,
        ),
      ),
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0, right: 5.0, left: 5.0),
      child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[               
              Container(
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Ninja baseball',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              coins < 0 ? '...' : coins.toString(),
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Image.asset(
                              'assets/other/coin2.png',
                              height: 32.0,
                              width: 32.0,
                            ),
                          ],
                        ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 30.0),
                child: Row(
                  children: <Widget>[
                    MenuButton('CHANGE CHARACTER', Icons.person),
                    MenuButton('CHANGE STAGE', Icons.landscape),
                    MenuButton('PLAY GAME', Icons.gamepad),
                    MenuButton('BUY BONUSES', Icons.attach_money),
                    MenuButton('CHANGE ENEMY', Icons.person_outline),
                  ],
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'High Score: '+ (highScore < 0 ? '...' : highScore.toString()),
                      style: TextStyle(fontSize: 20.0),
                    ),
                    IconButton(
                      icon: Icon(Icons.share),
                      iconSize: 20.0,
                      onPressed: () => print('I got a high score of $highScore'),
                    )
                ],
              ),
            ],
          ),
    );
  }
}