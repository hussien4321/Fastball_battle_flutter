import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io' show Platform;

class AdmobTools {
  
  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: <String>['B2AA47A5B61A62208DFAF5C4CD83EB0A', 'a4d0c870e8ac15dc1b13d5be2d248dbb'],
    keywords: <String>['game', 'fun', 'casual', 'arcade', 'endless game', 'baseball', 'battle'],
  );

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