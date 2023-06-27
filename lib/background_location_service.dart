import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:remindme/notification_manager.dart';
import 'package:remindme/notifier.dart';

import 'main.dart';

initializeService() async {
  await serviceBackground.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      // initialNotificationTitle: 'RemindMe',
      autoStart: true,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
onStart(ServiceInstance service) {
  print('<><><><><><> Service Started <><><><><><>');
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    NotificationManager.initializeNotification();
    service.setForegroundNotificationInfo(
      title: "RemindMe",
      content: "",
    );

    giveAlert();
  }

  service.on('stopService').listen((event) {
    print('Service Stopped');
    service.stopSelf();
  });
}
