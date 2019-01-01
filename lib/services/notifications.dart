import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter/material.dart';

//TODO: Make singleton
class NotificationService {

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static NotificationDetails _platformChannelSpecifics;

  static final NotificationService _singleton = new NotificationService._internal();

  static final int reminderId1 = 21344243;
  static final int reminderId2 = 21344123;
  static final int reminderId3 = 21344232;


  factory NotificationService() {
    return _singleton;
  }

  NotificationService._internal(){
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'ninja_baseball_notif_channel',
      'Reminders',
      'Reminds the user to beat their high score',
      icon: 'ic_launcher',
      color: Colors.redAccent,
      playSound: false,
      importance: Importance.Default, 
      priority: Priority.Default,
      style: AndroidNotificationStyle.BigText
      );
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails();
    _platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }


  createReminderNotification(int highScore, int nextUnlockable) async {
    await _flutterLocalNotificationsPlugin.cancel(reminderId1);
    await _flutterLocalNotificationsPlugin.cancel(reminderId2);
    await _flutterLocalNotificationsPlugin.cancel(reminderId3);


    var scheduledNotificationDateTime =
      DateTime.now().add(new Duration(days:3));

      String header = nextUnlockable == 10000000 ? "Giving up?":'${nextUnlockable-highScore} points away from next unlockable!';
      String message = "Can't beat your score of $highScore? are you too 🐔?";

      await _flutterLocalNotificationsPlugin.schedule(
          reminderId1,
          header,
          message,
          scheduledNotificationDateTime,
          _platformChannelSpecifics);

    scheduledNotificationDateTime =
      DateTime.now().add(new Duration(days:5));

      header = 'Come back and beat your high score!';
      message = nextUnlockable == 10000000 ? "Your high score is impressive, but is that your best? 😈" :"Only $nextUnlockable points away from unlocking a new item! 🎁";

      await _flutterLocalNotificationsPlugin.schedule(
          reminderId2,
          header,
          message,
          scheduledNotificationDateTime,
          _platformChannelSpecifics);


   scheduledNotificationDateTime =
      DateTime.now().add(new Duration(days:7));

      header = 'Have you given up? 😢';
      message = "Now that you have had some time away, come back and beat your score of $highScore! 👊";

      await _flutterLocalNotificationsPlugin.schedule(
          reminderId3,
          header,
          message,
          scheduledNotificationDateTime,
          _platformChannelSpecifics);

  }

  

}