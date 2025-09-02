import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:the_red_apple/constants/app_constants.dart';

class MultiplNotificationService {
  static MultiplNotificationService? _instance;
  final FirebaseMessaging _firebase = FirebaseMessaging.instance;

  static const String kMoEngageDeeplinkURL = 'gcm_webUrl';

  static getInstance() {
    _instance ??= MultiplNotificationService._();
    return _instance;
  }

  MultiplNotificationService._();

  void init() {
    _firebase
      ..requestPermission()
      ..onTokenRefresh.listen(
        (fcmToken) => _onFCMTokenRefreshed(fcmToken),
      );
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationData(message.data);
    });
    _setUpHeadsUpNotifications();
    _handleOnTapNotificationViaLocalNotificationsPlugin();
  }

  void _handleNotificationData(Map<String, dynamic>? data) {}

  void _handleOnTapNotificationViaLocalNotificationsPlugin() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(AppConstants.ANDROID_NOTIFICATION_ICON_RESOURCE);
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        final String? payload = notificationResponse.payload;
        if (payload?.isNotEmpty == true) {
          try {
            _handleNotificationData(jsonDecode(payload!));
          } catch (e, st) {
            log(e.toString(), stackTrace: st);
          }
        }
      },
    );
  }

  void _onFCMTokenRefreshed(String token) {
    log("FCM Token: $token");
  }

  void _setUpHeadsUpNotifications() async {
    //For iOS
    _firebase.setForegroundNotificationPresentationOptions(alert: true);

    //For Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConstants.ANDROID_NOTIFICATION_CHANNEL_ID,
      AppConstants.ANDROID_NOTIFICATION_CHANNEL_NAME,
      description: AppConstants.ANDROID_NOTIFICATION_CHANNEL_DESC,
      importance: Importance.max,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: AppConstants.ANDROID_NOTIFICATION_ICON_RESOURCE,
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      },
    );
  }
}
