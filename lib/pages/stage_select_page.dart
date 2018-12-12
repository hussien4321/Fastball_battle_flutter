import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/stage.dart';

class StageSelectPage extends StatefulWidget {

  @override
  _StageSelectPage createState() => _StageSelectPage();
}

class _StageSelectPage extends State<StageSelectPage> with TickerProviderStateMixin{

  StatsLoader stats = new StatsLoader();
  ObjectsLoader objectsLoader;


  Stage currentStage;
  List<Stage> allStages = [];

  bool loading = true;

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {

    objectsLoader = new ObjectsLoader(context);

    int stageId = await stats.getPreference(StatsLoader.CURRENT_STAGE);


    allStages = objectsLoader.stages;
    currentStage = allStages.where((stage) => stage.id == stageId).toList()[0];

    setState(() {
      loading = false; 
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( body: loading ? Center(child: Text('[LOAD SCREEN GOES HERE]...')):  Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage(currentStage.src, bundle: DefaultAssetBundle.of(context)),
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
                        'Select Stage',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    height: 200.0,
                    width: 600.0,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(allStages.length, (index) {
                          return Container(child: Image.asset(allStages[index].src));
                        }),
                    ),
                  ),
                ],
              )
            ],
          ),
    ),
    );
  }
}