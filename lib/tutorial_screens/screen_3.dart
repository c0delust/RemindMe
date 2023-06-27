import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

class Screen3 extends StatelessWidget {
  const Screen3({super.key});

  getNotificationPermission() async {
    PermissionStatus perm = await Permission.notification.request();

    if (perm.isDenied) {
      debugPrint('notification Denied');
      perm = await Permission.notification.request();
    }
    if (perm.isGranted) {
      debugPrint('notification Granted');
      Get.offAll(
        () => MyHomePage(),
        transition: Transition.leftToRightWithFade,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(right: 20, left: 20),
              child: Text(
                'Allow Push Notification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 246, 127, 102),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Image.asset(
                'assets/images/permission_3.png',
                // height: 200,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => getNotificationPermission(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color.fromARGB(255, 246, 127, 102),
                ),
                child: Text('Allow Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
