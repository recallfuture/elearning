import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  FlutterLocalNotificationsPlugin _notifications;
  static LocalNotification instance;

  // 初始化
  Future init() async {
    _notifications = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS
    );

    await _notifications.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification
    );

    await _notifications.cancelAll();
  }

  Future<void> onDidReceiveLocalNotification(int id, String title, String body, String payload) async {}

  Future<void> onSelectNotification(String payload) async {}

  // 设置一个定时通知
  schedule(DateTime scheduleDate, String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'elearning',
        'elearning',
        '查作业',
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics
    );

    await _notifications.schedule(
        0,
        title,
        body,
        scheduleDate,
        platformChannelSpecifics
    );
  }
}