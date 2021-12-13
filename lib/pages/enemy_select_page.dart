import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import '../helpers/views/enemy_view.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/enemy.dart';
import 'package:audioplayers/audioplayers.dart';

class EnemySelectPage extends StatefulWidget {
  AudioCache tonesPlayer;
  bool isTonesOn;

  EnemySelectPage(this.tonesPlayer, this.isTonesOn);

  @override
  _EnemySelectPage createState() => _EnemySelectPage();
}

class _EnemySelectPage extends State<EnemySelectPage>
    with TickerProviderStateMixin {
  StatsLoader stats = new StatsLoader();
  ObjectsLoader objectsLoader;

  int currIndex;
  int selectedIndex;
  int currHighScore;

  bool allCharsUnlocked = false;

  List<Enemy> allEnemies = [];

  bool loading = true;

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    objectsLoader = new ObjectsLoader(context);

    allCharsUnlocked =
        await stats.getPreference(StatsLoader.ALL_ITEMS_UNLOCKED_STATUS);

    int enemyId = await stats.getPreference(StatsLoader.CURRENT_ENEMY);
    currHighScore = await stats.getPreference(StatsLoader.HIGH_SCORE);
    stats.updatePreference(StatsLoader.ENEMY_PAGE_SCORE, currHighScore);

    allEnemies = objectsLoader.enemies;

    Enemy currentEnemy =
        allEnemies.where((enemy) => enemy.id == enemyId).toList()[0];
    currIndex = allEnemies.indexOf(currentEnemy);
    selectedIndex = currIndex;

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    if (widget.isTonesOn) {
      widget.tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
    }
    super.dispose();
  }

  void prevItem() {
    int newIndex = currIndex - 1;
    if (newIndex >= 0) {
      if (widget.isTonesOn) {
        widget.tonesPlayer.play(ObjectsLoader.CLICK_TONE);
      }
      setState(() {
        currIndex = newIndex;
      });
    }
  }

  void nextItem() {
    int newIndex = currIndex + 1;
    if (newIndex < allEnemies.length) {
      if (widget.isTonesOn) {
        widget.tonesPlayer.play(ObjectsLoader.CLICK_TONE);
      }
      setState(() {
        currIndex = newIndex;
      });
    }
  }

  void updateToIndex(newIndex) {
    stats.updatePreference(StatsLoader.CURRENT_ENEMY, allEnemies[newIndex].id);
    if (widget.isTonesOn) {
      widget.tonesPlayer.play(ObjectsLoader.SELECT_TONE);
    }
    setState(() {
      selectedIndex = newIndex;
    });
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: Text('LOADING...'))
          : Container(
              color: Colors.orangeAccent,
              padding: EdgeInsets.only(
                  top: 30.0, bottom: 10.0, right: 5.0, left: 5.0),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.orange[100]),
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: _goBack,
                            iconSize: 30.0,
                          ),
                        ),
                        Expanded(
                          child: Container(
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
                        ),
                        Opacity(
                          opacity: 0.0,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            iconSize: 30.0,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                        child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                              child: GestureDetector(
                            onTap: () => prevItem(),
                            child: Image.asset((currIndex - 1 < 0)
                                ? 'assets/other/left_gray.png'
                                : 'assets/other/left_button.png'),
                          )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                        Expanded(
                            flex: 3,
                            child: (currIndex - 1 < 0)
                                ? Container()
                                : EnemyView(
                                    enemy: allEnemies[currIndex - 1],
                                    selected: currIndex - 1 == selectedIndex,
                                    unlocked: allEnemies[currIndex - 1]
                                                .unlockThreshold <=
                                            currHighScore ||
                                        allCharsUnlocked,
                                    onClick: () =>
                                        updateToIndex(currIndex - 1))),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                        Expanded(
                            flex: 5,
                            child: EnemyView(
                                enemy: allEnemies[currIndex],
                                selected: currIndex == selectedIndex,
                                unlocked:
                                    allEnemies[currIndex].unlockThreshold <=
                                            currHighScore ||
                                        allCharsUnlocked,
                                onClick: () => updateToIndex(currIndex))),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                        Expanded(
                            flex: 3,
                            child: (currIndex + 1 >= allEnemies.length)
                                ? Container()
                                : EnemyView(
                                    enemy: allEnemies[currIndex + 1],
                                    selected: currIndex + 1 == selectedIndex,
                                    unlocked: allEnemies[currIndex + 1]
                                                .unlockThreshold <=
                                            currHighScore ||
                                        allCharsUnlocked,
                                    onClick: () =>
                                        updateToIndex(currIndex + 1))),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                              child: GestureDetector(
                            onTap: () => nextItem(),
                            child: Image.asset(
                                (currIndex + 1 >= allEnemies.length)
                                    ? 'assets/other/right_gray.png'
                                    : 'assets/other/right_button.png'),
                          )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
    );
  }
}
