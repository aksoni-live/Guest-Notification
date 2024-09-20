import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:guest_notification/utils/shared_pref_helper.dart';

import 'history_screen.dart';
import 'notification_screen.dart';

String fcmToken = '';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefHelper.initPref();

  await initializeFirebase();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorKey: navigatorKey,
    initialRoute: '/',
    routes: {
      '/': (context) => NotificationScreen(),
      '/notification': (context) => NotificationScreen(),
      '/history': (context) => HistoryScreen(),
    },
  ));
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
  await initializeLocalNotifications();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  fcmToken = (await messaging.getToken())!;
  print('FCM Token: $fcmToken');
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;

    if (kDebugMode) {
      print('Foreground message: ${message.data}');
    }

    // Assuming you want to show a guest notification with details
    if (notification != null) {
      showNotification(notification);

      // You can now extract guest details from the 'data' payload
      String guestId = data['guestId'] ?? 'Unknown';
      SharedPrefHelper.setUserId(guestId);
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification',
        (route) => false, // Remove all previous routes
        arguments: guestId,
      );
    }
  });
}

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification(RemoteNotification notification) async {
  final int notificationId = Random().nextInt(10000);
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'default_channel_id',
    'Default Channel',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    notificationId,
    notification?.title,
    notification?.body,
    platformChannelSpecifics,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  Map<String, dynamic> data = message.data;

  print('Handling a background message ${message.notification?.body}');

  if (notification != null && android != null) {
    showNotification(notification);
    String guestId = data['guestId'] ?? 'Unknown';
    SharedPrefHelper.setUserId(guestId);

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/notification',
      (route) => false, // Remove all previous routes
      arguments: guestId,
    );
  }
}
