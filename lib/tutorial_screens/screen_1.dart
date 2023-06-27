import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remindme/tutorial_screens/screen_2.dart';

class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  getLocationWhenInUsePermission() async {
    PermissionStatus perm = await Permission.locationWhenInUse.request();

    if (perm.isDenied) {
      debugPrint('locationWhenInUse Denied');
      perm = await Permission.locationWhenInUse.request();
    }
    if (perm.isGranted) {
      debugPrint('locationWhenInUse Granted');
      Get.offAll(
        () => Screen2(),
        transition: Transition.leftToRightWithFade,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 20, left: 20),
                  child: Text(
                    'Allow your Location',
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
                    'assets/images/permission_1.png',
                    // height: 200,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => getLocationWhenInUsePermission(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: const Color.fromARGB(255, 246, 127, 102),
                    ),
                    child: Text('Allow Location'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
