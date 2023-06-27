import 'package:flutter/material.dart';
import 'package:remindme/main.dart';
import 'package:remindme/models/reminder_model.dart';
import 'package:remindme/widgets/reminder_view.dart';
import 'package:hive_flutter/adapters.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Center(
            child: ValueListenableBuilder<Box<ReminderModel>>(
              valueListenable: MyApp.reminderBox.listenable(),
              builder: (context, value, child) {
                serviceBackground.on('restart');
                var data = MyApp.reminderBox.values
                    .toList()
                    .where((element) => element.isEnabled == true)
                    .toList()
                    .cast<ReminderModel>();

                return data.length != 0
                    ? ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          if (data.length - 1 == index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ReminderView(
                                  reminderModel: data[index],
                                  isActive: true,
                                ),
                                Text(
                                  'Double tap to Edit Task',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          }

                          return ReminderView(
                            reminderModel: data[index],
                            isActive: true,
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/location_reminder.jpg',
                            width: 150,
                            color: Color.fromRGBO(252, 81, 29, 0.5),
                            colorBlendMode: BlendMode.color,
                          ),
                          Text(
                            'No Reminders Found',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromRGBO(108, 25, 0, 0.498),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}
