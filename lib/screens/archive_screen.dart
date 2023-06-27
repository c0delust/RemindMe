import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../main.dart';
import '../models/reminder_model.dart';
import '../widgets/reminder_view.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

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
                var data = MyApp.reminderBox.values
                    .toList()
                    .where((element) => element.isEnabled == false)
                    .toList()
                    .cast<ReminderModel>();
                return data.length != 0
                    ? ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ReminderView(
                            reminderModel: data[index],
                            isActive: false,
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no_archive.png',
                            width: 200,
                            // color: Color.fromRGBO(252, 81, 29, 0.5),
                            colorBlendMode: BlendMode.color,
                          ),
                          Text(
                            'No Archives Found',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(108, 25, 0, 0.498),
                            ),
                          ),
                          Text(
                            'Slide Tasks to add to Archive',
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
