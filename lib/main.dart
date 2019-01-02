import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/main_page.dart';
import './services/objects_loader.dart';
import './services/stats_loader.dart';
import './services/notifications.dart';
import 'package:firebase_admob/firebase_admob.dart';
import './services/admob_tools.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _lockOrientation();
    _initializeServices(context);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fastball Battle',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          body1: TextStyle(fontFamily: 'Bungee'),
        ),
      ),
      home: Scaffold(
        body: MainPage(context),
      ),
    );
  }

  void _lockOrientation(){
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _initializeServices(BuildContext context) async {
    new StatsLoader();
    new ObjectsLoader(context);
    new NotificationService();

    _initializeAds();
  }
  void _initializeAds() async {
    await FirebaseAdMob.instance.initialize(appId: AdmobTools.appId);
  }

}