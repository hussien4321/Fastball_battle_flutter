import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import '../helpers/views/stage_view.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/stage.dart';

class StageSelectPage extends StatefulWidget {

  @override
  _StageSelectPage createState() => _StageSelectPage();
}

class _StageSelectPage extends State<StageSelectPage> with TickerProviderStateMixin{

  StatsLoader stats = new StatsLoader();
  ObjectsLoader objectsLoader;

  int currIndex;
  int selectedIndex;
  int currHighScore;

  List<Stage> allStages = [];

  bool loading = true;

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {

    objectsLoader = new ObjectsLoader(context);

    int stageId = await stats.getPreference(StatsLoader.CURRENT_STAGE);
    currHighScore = await stats.getPreference(StatsLoader.HIGH_SCORE);
    stats.updatePreference(StatsLoader.STAGE_PAGE_SCORE, currHighScore);

    allStages = objectsLoader.stages;

    Stage currentStage = allStages.where((stage) => stage.id == stageId).toList()[0];
    currIndex = allStages.indexOf(currentStage);
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
    if(newIndex < allStages.length){
      setState(() {
        currIndex = newIndex;
      });
    }
  }

  void updateToIndex(newIndex) {
    stats.updatePreference(StatsLoader.CURRENT_STAGE, allStages[newIndex].id);

    setState(() {
      selectedIndex = newIndex;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( body: loading ? Center(child: Text('[LOAD SCREEN GOES HERE]...')):  Container(
      // decoration: BoxDecoration(
      //   image: new DecorationImage(
      //     image: new AssetImage(currentStage.src, bundle: DefaultAssetBundle.of(context)),
      //     fit: BoxFit.fill,
      //   ),
      // ),
      color: Colors.orangeAccent,
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0, right: 5.0, left: 5.0),
      child: Column(
            children: <Widget>[               
              Container(
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
                        child: (currIndex-1 < 0) ? Container() : StageView(
                          stage: allStages[currIndex-1], 
                          selected: currIndex-1 == selectedIndex, 
                          unlocked: allStages[currIndex-1].unlockThreshold <= currHighScore,
                          onClick: () => updateToIndex(currIndex-1)
                        )
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      Expanded(
                        flex: 5,
                        child: StageView(
                          stage: allStages[currIndex], 
                          selected: currIndex == selectedIndex, 
                          unlocked: allStages[currIndex].unlockThreshold <= currHighScore,
                          onClick: () => updateToIndex(currIndex)
                        )
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      Expanded(
                        flex: 3,
                        child: (currIndex+1 >= allStages.length) ? Container() : StageView(
                          stage: allStages[currIndex+1], 
                          selected: currIndex+1 == selectedIndex, 
                          unlocked: allStages[currIndex+1].unlockThreshold <= currHighScore,
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
                              (currIndex+1 >= allStages.length) ? 'assets/other/right_gray.png' : 'assets/other/right_button.png'
                            ),
                          ) 
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      // Container(
                      //   height: 200.0,
                      //   width: 600.0,
                      //   child: ListView(
                      //     scrollDirection: Axis.horizontal,
                      //     children: List.generate(allStages.length, (index) {
                      //         return Container(child: Image.asset(allStages[index].src));
                      //       }),
                      //   ),
                      // ),
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