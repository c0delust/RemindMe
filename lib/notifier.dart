import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:remindme/models/reminder_model.dart';
import 'notification_manager.dart';

giveAlert() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0))
    Hive.registerAdapter(ReminderModelAdapter());
  // ignore: unused_local_variable
  final openedBox = await Hive.openBox<ReminderModel>('reminderBox');

  try {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
    );
    // ignore: unused_local_variable
    final StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) async {
        final box = await Hive.openBox<ReminderModel>('reminderBox');
        // var prefs = await SharedPreferences.getInstance();
        // prefs.reload();

        print('Stream Called');

        final List<ReminderModel> list = box.values
            .toList()
            .where((element) =>
                element.isEnabled == true && element.isDone != true)
            .toList()
            .cast<ReminderModel>();

        print('Lenght: ' + list.length.toString());

        list.forEach((element) {
          double distanceInMeters = Geolocator.distanceBetween(element.latitude,
              element.longitude, position!.latitude, position.longitude);
          if (distanceInMeters <= element.radius) {
            print('title: ' + element.title);

            String uniqueId = UniqueKey().toString();

            NotificationManager.showNotification(
              id: uniqueId.hashCode,
              title: element.title,
              body: element.description,
            );

            element.isDone = true;
            element.save();
          }
        });

        box.close();
      },
    );
  } catch (error) {}
}
