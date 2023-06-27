import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/get_controller.dart';

// ignore: must_be_immutable
class BottomNavButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final int value;
  BottomNavButton(
      {super.key, required this.text, required this.icon, required this.value});

  Color focusedColor = Colors.white;
  Color unFocusedColor = Color.fromRGBO(255, 221, 194, 1);

  final controller = Get.find<Get_Controller>();

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onPressed: () => controller.currentIndex.value = value,
      child: Obx(() => Column(
            children: [
              Icon(
                icon,
                color: controller.currentIndex.value == value
                    ? focusedColor
                    : unFocusedColor,
                size: controller.currentIndex.value == value ? 25 : 20,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: controller.currentIndex.value == value
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: controller.currentIndex.value == value
                      ? focusedColor
                      : unFocusedColor,
                ),
              ),
            ],
          )),
    );
  }
}
