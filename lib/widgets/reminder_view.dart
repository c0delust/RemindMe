import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:remindme/models/reminder_model.dart';
import 'package:remindme/screens/edit_reminder_screen.dart';

// ignore: must_be_immutable
class ReminderView extends StatelessWidget {
  final ReminderModel reminderModel;
  final bool isActive;

  ReminderView({
    super.key,
    required this.reminderModel,
    required this.isActive,
  });

  var leadingColor = Color.fromRGBO(215, 114, 12, 0.8);
  RxBool? isDone;
  RxBool? isDismissed;

  showSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        content: Text(
          title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isDone = reminderModel.isDone.obs;
    isDismissed = reminderModel.isEnabled.obs;

    return Slidable(
      endActionPane: ActionPane(
        motion: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: BehindMotion(),
        ),
        children: [
          isActive
              ? SlidableAction(
                  // label: 'Add to Archive',
                  icon: Icons.archive,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Color.fromARGB(255, 229, 90, 80),
                  onPressed: (context) {
                    toggleArchive(context);
                    showSnackBar(context, 'Task Archived');
                  },
                )
              : SlidableAction(
                  // label: 'Remove from Archive',
                  icon: Icons.unarchive_outlined,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Color.fromRGBO(75, 184, 130, 1),
                  // backgroundColor: Color.fromARGB(255, 127, 229, 80),
                  onPressed: (context) {
                    toggleArchive(context);
                    showSnackBar(context, 'Task Unarchived');
                  },
                ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          elevation: 1.6,
          shadowColor: Color.fromRGBO(255, 239, 226, 1),
          child: GestureDetector(
            onDoubleTap: () {
              if (isActive) {
                Get.to(
                  () => EditReminder(
                    reminderModel: reminderModel,
                  ),
                  transition: Transition.downToUp,
                );
              }
            },
            child: ListTile(
              tileColor: Color.fromRGBO(255, 244, 237, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    'assets/images/location_radius.png',
                    height: 25,
                    alignment: Alignment.center,
                    color: leadingColor,
                  ),
                  Text(
                    reminderModel.radius.toString() + 'm',
                    style: TextStyle(
                      fontSize: 15,
                      color: leadingColor,
                    ),
                  )
                ],
              ),
              title: Text(
                reminderModel.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                reminderModel.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                splashRadius: 25,
                splashColor: Color.fromRGBO(255, 225, 200, 1),
                onPressed: updateStatus,
                icon: Obx(
                  () => Icon(
                    isDone!.value
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isDone!.value
                        ? Colors.green
                        : Color.fromARGB(255, 176, 176, 176),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  updateStatus() {
    if (isActive) {
      isDone!.value = !isDone!.value;
      reminderModel.isDone = isDone!.value;
      reminderModel.save();
    }
  }

  toggleArchive(BuildContext context) async {
    reminderModel.isDone = false;
    reminderModel.isEnabled = !reminderModel.isEnabled;
    reminderModel.save();
  }
}
