import 'package:flutter/material.dart';
import '../helpers/views/menu_button.dart';
import '../services/stats_loader.dart';
import '../services/objects_loader.dart';
import './game_page.dart';
import '../helpers/views/payment_view.dart';
import '../services/admob_tools.dart';
import '../services/check_connection.dart';
import '../helpers/views/custom_page_routes.dart';
import '../models/enemy.dart';
import 'package:audioplayers/audioplayers.dart';
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

class _PaymentsPageState extends State<PaymentsPage>
    with TickerProviderStateMixin {
  String _platformVersion = 'Unknown';

  List<String> _purchasedIds = [];
  List<IAPItem> _items = [];

  bool hasConnection = true;
  bool restoring = false;
  bool purchasing = false;

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
    allCharsUnlocked =
        await stats.getPreference(StatsLoader.ALL_ITEMS_UNLOCKED_STATUS);
    adsPaidStatus = await stats.getPreference(StatsLoader.ADS_PAID_STATUS);
    setState(() {
      loading = false;
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    await FlutterInappPurchase.instance.initialize();

    await initPurchases();

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  initPurchases() async {
    List<PurchasedItem> purchasedItems =
        await FlutterInappPurchase.instance.getAvailablePurchases();
    List<String> purchasedIds = purchasedItems
        .map((purchased) => purchased.productId.toString())
        .toList();

    List<IAPItem> items = await FlutterInappPurchase.instance
        .getProducts(AdmobTools.productsList);

    if (mounted) {
      setState(() {
        _purchasedIds = purchasedIds;
        _items = items;
      });
    }
  }

  @override
  void dispose() {
    if (widget.isTonesOn) {
      widget.tonesPlayer.play(ObjectsLoader.PAGE_NAV_TONE);
    }
    super.dispose();
  }

  void _buyProduct(String prodId) async {
    List<IAPItem> result =
        _items.where((item) => item.productId == prodId).toList();
    print('buying item ${_items.length} -> ${result.length}');
    if (result.length != 0) {
      PurchasedItem purchased = await FlutterInappPurchase.instance
          .requestPurchase(result[0].productId);
      print('purcuased - ${purchased.toString()}');
      if (purchased != null) {
        print('successfully finsihing!');
        stats.updatePreference(StatsLoader.ADS_PAID_STATUS, true);
        setState(() {
          allCharsUnlocked = true;
        });
        if (widget.isTonesOn) {
          widget.tonesPlayer.play(ObjectsLoader.SELECT_TONE);
        }
      }
    }
  }

  void _restorePurchases() async {
    setState(() {
      restoring = true;
    });
    await initPurchases();

    hasConnection = await CheckConnection.checkConnection();

    if (hasConnection) {
      for (var item in _items) {
        bool isBought = _purchasedIds.contains(item.productId);

        print('SETTING ${item.productId} to $isBought');
        if (item.productId == AdmobTools.unlockAllItemsProduct) {
          stats.updatePreference(
              StatsLoader.ALL_ITEMS_UNLOCKED_STATUS, isBought);
          setState(() {
            allCharsUnlocked = isBought;
          });
        } else if (item.productId == AdmobTools.removeAdsProduct) {
          stats.updatePreference(StatsLoader.ADS_PAID_STATUS, isBought);
          setState(() {
            adsPaidStatus = isBought;
          });
        }
      }
      setState(() {
        restoring = false;
      });
    } else {
      setState(() {
        hasConnection = false;
      });
    }
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
                    child: Stack(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Opacity(
                              opacity: 0.0,
                              child: RaisedButton(
                                child: Text(
                                  !hasConnection
                                      ? 'No connection'
                                      : (!restoring
                                          ? 'Restore'
                                          : 'Restoring...'),
                                  style: Theme.of(context).textTheme.bodyText1,
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
                                !hasConnection
                                    ? 'No connection'
                                    : (!restoring ? 'Restore' : 'Restoring...'),
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              color: Colors.orange[100],
                              onPressed: hasConnection && !restoring
                                  ? _restorePurchases
                                  : null,
                            ),
                          ],
                        ),
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
                            child: PaymentView(
                                image: Image.asset(
                                  'assets/other/unlock_all.png',
                                  fit: BoxFit.contain,
                                ),
                                paymentName: 'Unlock everything',
                                paymentDescription:
                                    "Get access to all characters, enemies and stages in the game!",
                                unlocked: allCharsUnlocked,
                                onClick: () => _buyProduct(
                                    AdmobTools.unlockAllItemsProduct))),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                        Expanded(
                            child: PaymentView(
                                image: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      color: Colors.redAccent),
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
                                paymentDescription:
                                    "Enjoy the fastball battle experience with no ads!",
                                unlocked: adsPaidStatus,
                                onClick: () =>
                                    _buyProduct(AdmobTools.removeAdsProduct))),
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
