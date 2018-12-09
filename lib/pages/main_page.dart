import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import './game_page.dart';
import '../helpers/views/custom_page_routes.dart';

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
          image: new AssetImage("assets/backgrounds/3.png", bundle: DefaultAssetBundle.of(context)),
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
                            Material(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                              color: Colors.orange[100],
                              child: Container(
                                height: 32.0,
                                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                child: Center(
                                  child: Text(
                                    coins < 0 ? '...' : coins.toString(),
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              borderRadius: BorderRadius.only(topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0)),
                              color: Colors.orange[100],
                              child: Image.asset(
                                'assets/other/coin.png',
                                height: 32.0,
                                width: 32.0,
                              ),
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
                    MenuButton('CHANGE CHARACTER', Icons.person, () => print('clicked')),
                    MenuButton('CHANGE STAGE', Icons.landscape, () => print('clicked')),
                    MenuButton('PLAY GAME', Icons.gamepad, () {
                      Navigator.push(
                        context,
                        CustomPageRoute(builder: (context) => GamePage(context)),
                      );
                    }),
                    MenuButton('BUY BONUSES', Icons.attach_money, () => print('clicked')),
                    MenuButton('CHANGE ENEMY', Icons.person_outline, () => print('clicked')),
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