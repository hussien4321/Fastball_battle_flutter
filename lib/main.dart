import 'package:flutter/material.dart';
import './pages/game_page.dart';
import 'package:flutter/services.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _lockOrientation();
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
        body: GamePage(context),
      ),
    );
  }

    void _lockOrientation(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

}