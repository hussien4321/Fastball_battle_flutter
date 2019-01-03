import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io' show Platform;

class AdmobTools {
  
  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: <String>['B2AA47A5B61A62208DFAF5C4CD83EB0A', 'a4d0c870e8ac15dc1b13d5be2d248dbb'],
    keywords: <String>['game', 'fun', 'casual game', 'arcade', 'endless game', 'baseball', 'battle'],
  );

    final List<String> testProductsList = Platform.isAndroid
      ? [
    'android.test.purchased',
    'point_1000',
    '5000_point',
    'android.test.canceled',
  ]
      : ['com.cooni.point1000','com.cooni.point5000'];


  static final List<String> productsList = Platform.isAndroid
    ? ['fastball_battle_remove_ads' , 'fastball_battle_unlock_all_items']
    : ['fastball_battle_remove_ads' , 'fastball_battle_unlock_all_items'];

  static final String removeAdsProduct = Platform.isAndroid
    ? 'fastball_battle_remove_ads' : 'fastball_battle_remove_ads';

  static final String unlockAllItemsProduct = Platform.isAndroid
    ? 'fastball_battle_unlock_all_items' : 'fastball_battle_unlock_all_items';

  static final String testAppId = FirebaseAdMob.testAppId;

  static final String appId = Platform.isAndroid
      ? 'ca-app-pub-3787115292798141~7283579567'
      : 'ca-app-pub-3787115292798141~4418824646';

  static final String testAdUnitId = InterstitialAd.testAdUnitId;

  static final String interstitialAdUnitId =
   Platform.isAndroid
      ? 'ca-app-pub-3787115292798141/1398550268'
      : 'ca-app-pub-3787115292798141/8284071555';

}