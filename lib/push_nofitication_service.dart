import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/app/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class NotificationService {
  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> registerNotification(BuildContext context) async {
    _messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      sendFCM(context);
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage?.notification != null) {
        navigate(initialMessage?.data, context);
      }
      FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) => foregroundNotification(message, context));
      FirebaseMessaging.onMessageOpenedApp
          .listen((message) => navigate(message.data, context));
    } else {
      print('User declined or has not accepted permission');
    }
  }

  foregroundNotification(RemoteMessage message, BuildContext context) async {
    await initNotification(context);
    const notificationSpecs = NotificationDetails(
      iOS: IOSNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        'id',
        'name',
        channelDescription: 'description',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    print(message.notification?.bodyLocArgs);
    print(message.notification?.bodyLocKey);
    print(message.notification?.title);
    print(message.notification?.body);
    print(message.data);
    flutterLocalNotificationsPlugin.show(
        math.Random().nextInt(100000),
        message.notification?.title ?? '',
        message.notification?.body ?? '',
        notificationSpecs,
        payload: json.encode(message.data));
  }

  void onSelectNotification(String? payload, BuildContext context) {
    if (payload != null) {
      Map<String, dynamic> message = json.decode(payload);
      navigate(message, context);
    }
  }

  void navigate(Map<String, dynamic>? message, BuildContext context) {
    print(message);
    if (message != null && message.containsKey('data')) {
      if (message["data"]) {
        Navigator.of(context).pushNamed(ChatScreen.routeName, arguments: {
          "estate_id": message["data"]["estate_id"],
          "user_id": message["data"]["user_id"]
        });
      }
    }
  }

  Future<void> initNotification(BuildContext context) async {
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) => onSelectNotification(payload, context),
    );
  }

  void sendFCM(BuildContext context) async {
    print('send');
    if (_messaging == null) {
      await registerNotification(context);
    } else {
      if (Platform.isIOS) {
        _messaging?.getAPNSToken().then((value) {
          print('send1');
          _messaging?.getToken().then((token) {
            print('send2');
            print('FCM $token');
            Provider.of<AuthProvider>(context, listen: false)
                .updateFCM(token.toString());
          });
        });
      } else if (Platform.isAndroid) {
        _messaging?.getToken().then((token) {
          print('FCM $token');
          Provider.of<AuthProvider>(context, listen: false)
              .updateFCM(token.toString());
        });
      }
    }
  }
}
