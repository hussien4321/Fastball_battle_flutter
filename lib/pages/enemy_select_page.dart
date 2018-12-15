import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import '../helpers/views/enemy_view.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/enemy.dart';

class EnemySelectPage extends StatefulWidget {

  @override
  _EnemySelectPage createState() => _EnemySelectPage();
}

class _EnemySelectPage extends State<EnemySelectPage> with TickerProviderStateMixin{

  StatsLoader stats = new StatsLoader();
  ObjectsLoader objectsLoader;

  int currIndex;
  int selectedIndex;
  int currHighScore;

  List<Enemy> allEnemies = [];

  bool loading = true;

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {

    objectsLoader = new ObjectsLoader(context);

    int enemyId = await stats.getPreference(StatsLoader.CURRENT_ENEMY);
    currHighScore = await stats.getPreference(StatsLoader.HIGH_SCORE);
    stats.updatePreference(StatsLoader.ENEMY_PAGE_SCORE, currHighScore);

    allEnemies = objectsLoader.enemies;

    Enemy currentEnemy = allEnemies.where((enemy) => enemy.id == enemyId).toList()[0];
    currIndex = allEnemies.indexOf(currentEnemy);
    selectedIndex = currIndex;

    setState(() {
      loading = false; 
      
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void prevItem() {
    int newIndex = currIndex - 1;
    if(newIndex >= 0){
      setState(() {
        currIndex = newIndex;
      });
    }
  }
  void nextItem() {
    int newIndex = currIndex + 1;
    if(newIndex < allEnemies.length){
      setState(() {
        currIndex = newIndex;
      });
    }
  }

  void updateToIndex(newIndex) {
    stats.updatePreference(StatsLoader.CURRENT_CHARACTER, allEnemies[newIndex].id);

    setState(() {
      selectedIndex = newIndex;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( body: loading ? Center(child: Text('LOADING...')):  Container(
      color: Colors.orangeAccent,
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0, right: 5.0, left: 5.0),
      child: Column(
            children: <Widget>[               
              Container(
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Select Enemy',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: GestureDetector(
                            onTap: () => prevItem(),
                            child: Image.asset(
                              (currIndex-1 < 0) ? 'assets/other/left_gray.png' : 'assets/other/left_button.png'
                            ),
                          ) 
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      Expanded(
                        flex: 3,
                        child: (currIndex-1 < 0) ? Container() : EnemyView(
                          enemy: allEnemies[currIndex-1], 
                          selected: currIndex-1 == selectedIndex, 
                          unlocked: allEnemies[currIndex-1].unlockThreshold <= currHighScore,
                          onClick: () => updateToIndex(currIndex-1)
                        )
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      Expanded(
                        flex: 5,
                        child: EnemyView(
                          enemy: allEnemies[currIndex], 
                          selected: currIndex == selectedIndex, 
                          unlocked: allEnemies[currIndex].unlockThreshold <= currHighScore,
                          onClick: () => updateToIndex(currIndex)
                        )
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      Expanded(
                        flex: 3,
                        child: (currIndex+1 >= allEnemies.length) ? Container() : EnemyView(
                          enemy: allEnemies[currIndex+1], 
                          selected: currIndex+1 == selectedIndex, 
                          unlocked: allEnemies[currIndex+1].unlockThreshold <= currHighScore,
                          onClick: () => updateToIndex(currIndex+1)
                        )
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: GestureDetector(
                            onTap: () => nextItem(),
                            child: Image.asset(
                              (currIndex+1 >= allEnemies.length) ? 'assets/other/right_gray.png' : 'assets/other/right_button.png'
                            ),
                          ) 
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                    ],
                  )
                ),
              ),
            ],
          ),
    ),
    );
  }
}