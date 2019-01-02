import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import '../helpers/views/payment_view.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/enemy.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter/services.dart';
import 'dart:io';


class PaymentsPage extends StatefulWidget {

  AudioCache tonesPlayer;
  bool isTonesOn;

  PaymentsPage(this.tonesPlayer, this.isTonesOn);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> with TickerProviderStateMixin{
  final List<String>_productLists = Platform.isAndroid
      ? [
    'android.test.purchased',
    'point_1000',
    '5000_point',
    'android.test.canceled',
  ]
      : ['com.cooni.point1000','com.cooni.point5000'];

  String _platformVersion = 'Unknown';
  List<IAPItem> _items = [];

  bool restoring = false;


  StatsLoader stats = new StatsLoader();
  ObjectsLoader objectsLoader;

  bool loading = true;

  bool allCharsUnlocked = false;
  bool adsPaidStatus = false;

  void initState() {
    super.initState();
    loadData();
    initPlatformState();
  }

  loadData() async {

    objectsLoader = new ObjectsLoader(context);
    allCharsUnlocked = await stats.getPreference(StatsLoader.ALL_ITEMS_UNLOCKED_STATUS);
    adsPaidStatus = await stats.getPreference(StatsLoader.ADS_PAID_STATUS);
    
    setState(() {
      loading = false; 
      
    });
  }

  
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterInappPurchase.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // initConnection
    var result = await FlutterInappPurchase.initConnection;
    print ('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    // refresh items for android
    String msg = await FlutterInappPurchase.consumeAllItems;
    print('consumeAllItems: $msg');
  }


  Future<Null> _getProducts() async {
    List<IAPItem> items = await FlutterInappPurchase.getProducts(_productLists);
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }

    setState(() {
      this._items = items;
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

  void _restorePurchases() async {
    setState(() {
      restoring=true;
    });
    await _getProducts();

    print('you have ${_items.length} items');

    //restore the purchases
    //update the states of ads and all items
    //turn the restore button back on
    
    setState(() {
      restoring=false;
    });
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
                  child: Stack(
                    children: <Widget> [
                      Row(
                       children: <Widget>[  
                        Opacity(
                          opacity: 0.0,
                          child: RaisedButton(
                            child: Text(
                              !restoring ? 'Restore' : 'Restoring...',
                              style: Theme.of(context).textTheme.body1,
                            ),
                            color: Colors.orange[100],
                            onPressed: null,
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
                        RaisedButton(
                          child: Text(
                            !restoring ? 'Restore' : 'Restoring...',
                            style: Theme.of(context).textTheme.body1,
                          ),
                          color: Colors.orange[100],
                          onPressed: !restoring ? _restorePurchases : null,
                        ),
                      ],
                    ),
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
                          paymentDescription: "Enjoy the fastball battle experience with no ads!",
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