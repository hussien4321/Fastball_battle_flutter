import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/main_page.dart';
import './services/objects_loader.dart';
import './services/stats_loader.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _lockOrientation();
    _initializeServices(context);
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baseball game',
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

  void _initializeServices(BuildContext context){
    new StatsLoader();
    new ObjectsLoader(context);
  }

}