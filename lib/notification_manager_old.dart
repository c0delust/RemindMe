// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'main.dart';

// Future initializeNotification(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//   AndroidInitializationSettings androidInitializationSettings =
//       AndroidInitializationSettings('mipmap/ic_launcher');
//   DarwinInitializationSettings darwinInitializationSettings =
//       DarwinInitializationSettings();
//   InitializationSettings initializationSettings = InitializationSettings(
//       android: androidInitializationSettings,
//       iOS: darwinInitializationSettings);

//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//   );
// }

// Future showNotification({
//   var id = 0,
//   required String title,
//   required String body,
//   var payload,
// }) async {
//   final prefs = await SharedPreferences.getInstance();
//   prefs.reload();

//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'channel_id_01',
//     "Reminders_01",
//   );

//   AndroidNotificationDetails androidNotificationDetails =
//       AndroidNotificationDetails(channel.id, channel.name,
//           color: Colors.amber,
//           icon: 'ic_bg_service_small',
//           playSound: false,
//           importance: Importance.max,
//           priority: Priority.high,
//           enableLights: true,
//           enableVibration: false,
//           actions: [
//         AndroidNotificationAction(
//           'action_id',
//           'Close',
//         ),
//       ]);

//   var notification = NotificationDetails(android: androidNotificationDetails);
//   await flutterLocalNotificationsPlugin
//       .show(notification.hashCode, title, body, notification)
//       .then((value) => print(''));

//   if (prefs.getBool('notificationKey')!) {
//     final AudioPlayer audioPlayer = AudioPlayer();
//     if (prefs.getStringList('fileKey') != null) {
//       if (prefs.getStringList('fileKey')![0] == 'Default') {
//         audioPlayer.setAsset('assets/audio/tone.mp3');
//         audioPlayer.play();
//       } else {
//         audioPlayer.setFilePath(prefs.getStringList('fileKey')![0]);
//         audioPlayer.play();
//       }
//     }
//   }

//   if (prefs.getBool('vibrateKey')!) {
//     HapticFeedback.vibrate();
//   }
// }
