import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import '../helpers/views/stage_view.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/stage.dart';
import 'package:audioplayers/audioplayers.dart';

class StageSelectPage extends StatefulWidget {
  AudioCache tonesPlayer;
  bool isTonesOn;

  StageSelectPage(this.tonesPlayer, this.isTonesOn);

  @override
  _StageSelectPage createState() => _StageSelectPage();
}

class _StageSelectPage extends State<StageSelectPage>
    with TickerProviderStateMixin {
  StatsLoader stats = new StatsLoader();
  ObjectsLoader objectsLoader;

  int currIndex;
  int selectedIndex;
  int currHighScore;

  List<Stage> allStages = [];

  bool allCharsUnlocked = false;
  bool loading = true;

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    objectsLoader = new ObjectsLoader(context);

    allCharsUnlocked =
        await stats.getPreference(StatsLoader.ALL_ITEMS_UNLOCKED_STATUS);
    int stageId = await stats.getPreference(StatsLoader.CURRENT_STAGE);
    currHighScore = await stats.getPreference(StatsLoader.HIGH_SCORE);
    stats.updatePreference(StatsLoader.STAGE_PAGE_SCORE, currHighScore);

    allStages = objectsLoader.stages;

    Stage currentStage =
        allStages.where((stage) => stage.id == stageId).toList()[0];
    currIndex = allStages.indexOf(currentStage);
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
    if (newIndex < allStages.length) {
      if (widget.isTonesOn) {
        widget.tonesPlayer.play(ObjectsLoader.CLICK_TONE);
      }
      setState(() {
        currIndex = newIndex;
      });
    }
  }

  void updateToIndex(newIndex) {
    stats.updatePreference(StatsLoader.CURRENT_STAGE, allStages[newIndex].id);
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
                                    'Select Stage',
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
                                : StageView(
                                    stage: allStages[currIndex - 1],
                                    selected: currIndex - 1 == selectedIndex,
                                    unlocked: allStages[currIndex - 1]
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
                            child: StageView(
                                stage: allStages[currIndex],
                                selected: currIndex == selectedIndex,
                                unlocked:
                                    allStages[currIndex].unlockThreshold <=
                                            currHighScore ||
                                        allCharsUnlocked,
                                onClick: () => updateToIndex(currIndex))),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                        Expanded(
                            flex: 3,
                            child: (currIndex + 1 >= allStages.length)
                                ? Container()
                                : StageView(
                                    stage: allStages[currIndex + 1],
                                    selected: currIndex + 1 == selectedIndex,
                                    unlocked: allStages[currIndex + 1]
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
                                (currIndex + 1 >= allStages.length)
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
