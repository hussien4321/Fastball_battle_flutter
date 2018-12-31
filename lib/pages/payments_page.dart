import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import '../helpers/views/payment_view.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/enemy.dart';
import 'package:audioplayers/audio_cache.dart';

class PaymentsPage extends StatefulWidget {

  AudioCache tonesPlayer;
  bool isTonesOn;

  PaymentsPage(this.tonesPlayer, this.isTonesOn);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> with TickerProviderStateMixin{

  StatsLoader stats = new StatsLoader();
  ObjectsLoader objectsLoader;

  bool loading = true;

  bool allCharsUnlocked = false;
  bool adsPaidStatus = false;

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {

    objectsLoader = new ObjectsLoader(context);
    allCharsUnlocked = await stats.getPreference(StatsLoader.ALL_ITEMS_UNLOCKED_STATUS);
    adsPaidStatus = await stats.getPreference(StatsLoader.ADS_PAID_STATUS);
    
    setState(() {
      loading = false; 
      
    });
  }

  @override
  void dispose() {
    if(widget.isTonesOn){
      widget.tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
    }
    super.dispose();
  }

  void _unlockEverything() {
    print('unlocking it allllll');

    stats.updatePreference(StatsLoader.ALL_ITEMS_UNLOCKED_STATUS, true);
    setState(() {
      allCharsUnlocked = true;
    });
    if(widget.isTonesOn){
      widget.tonesPlayer.play(ObjectsLoader.SELECT_TONE);
    }
  }

  void _removeAds() {
    print('remove ads');

    stats.updatePreference(StatsLoader.ADS_PAID_STATUS, true);
    setState(() {
      adsPaidStatus = true;
    });
    if(widget.isTonesOn){
      widget.tonesPlayer.play(ObjectsLoader.SELECT_TONE);
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( body: loading ? Center(child: Text('LOADING...')):  Container(
      color: Colors.orangeAccent,
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0, right: 5.0, left: 5.0),
      child: Column(
            children: <Widget>[          
              Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                  children: <Widget>[
                    Container( 
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.orange[100]
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _goBack,
                        iconSize: 30.0,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 15.0),
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Text(
                                'Buy bonuses',
                                style: TextStyle(fontSize: 30.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Opacity(
                        opacity: 0.0,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          iconSize: 30.0,
                        ),
                      )
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
                        child: PaymentView(
                          image: Image.asset(
                            'assets/other/unlock_all.png',
                            fit: BoxFit.contain,
                          ),
                          paymentName: 'Unlock everything',
                          paymentDescription: "Get access to all characters, enemies and stages in the game!",
                          unlocked: allCharsUnlocked,
                          onClick: _unlockEverything
                        )
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0),),
                      Expanded(
                        child: PaymentView(
                          image: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Colors.redAccent
                            ),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 65.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.stay_current_landscape,
                                    size: 95.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          paymentName: 'Remove Ads',
                          paymentDescription: "Enjoy the ninja baseball experience with no ads!",
                          unlocked: adsPaidStatus,
                          onClick: _removeAds
                        )
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