import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remindme/models/reminder_model.dart';
import 'package:remindme/screens/maps_screen.dart';
import '../widgets/radius_slider.dart';

// ignore: must_be_immutable
class EditReminder extends StatelessWidget {
  final ReminderModel reminderModel;
  EditReminder({
    super.key,
    required this.reminderModel,
  });
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final MapsScreen mapsScreen = MapsScreen();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  double sliderValue = 25.0;

  double? latitude;
  double? longitude;
  String? sublocality;

  initData() {
    titleController.text = reminderModel.title;
    descriptionController.text = reminderModel.description;
    locationController.text = locationController.text =
        "${reminderModel.location}\nLatitude: ${reminderModel.latitude}\nLongitude: ${reminderModel.longitude}";
    sliderValue = reminderModel.radius.toDouble();
    latitude = reminderModel.latitude;
    longitude = reminderModel.longitude;
    sublocality = reminderModel.location;
  }

  @override
  Widget build(BuildContext context) {
    initData();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                useSafeArea: true,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('Are you sure you want to Delete this Task?'),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 85, 85, 85),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 76, 67),
                        ),
                        onPressed: () {
                          reminderModel.delete();
                          Navigator.pop(context);
                          Get.back();
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.delete),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        title: Text('Edit'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(248, 181, 51, 1),
                Color.fromRGBO(252, 81, 29, 1),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(25),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 10,
                ),
                TextField(
                  enableSuggestions: true,
                  focusNode: titleFocusNode,
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 30,
                  maxLines: 1,
                  cursorColor: Color.fromARGB(255, 252, 139, 26),
                  decoration: new InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontSize: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color.fromARGB(255, 252, 139, 26),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color.fromARGB(255, 252, 139, 26),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  enableSuggestions: true,
                  keyboardType: TextInputType.multiline,
                  focusNode: descriptionFocusNode,
                  textCapitalization: TextCapitalization.sentences,
                  controller: descriptionController,
                  maxLength: 150,
                  maxLines: 5,
                  cursorColor: Color.fromARGB(255, 252, 139, 26),
                  decoration: new InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 104, 104, 104),
                      fontSize: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color.fromARGB(255, 252, 139, 26),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color.fromARGB(255, 252, 139, 26),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                RadiusSlider(
                    onChanged: (value) => sliderValue = value,
                    sliderValue: sliderValue),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    titleFocusNode.unfocus();
                    descriptionFocusNode.unfocus();

                    Get.to(
                      () => mapsScreen,
                      transition: Transition.rightToLeft,
                      arguments: {
                        'LatLng': LatLng(latitude!, longitude!),
                        'radius': sliderValue,
                        'sublocality': sublocality,
                      },
                    )!
                        .then((value) {
                      if (value != null) {
                        locationController.text =
                            "${value['sublocality']}\nLatitude: ${value['latitude']}\nLongitude: ${value['longitude']}";
                        sublocality = value['sublocality'];
                        latitude = value['latitude'];
                        longitude = value['longitude'];
                      }
                    });
                  },
                  child: TextField(
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    controller: locationController,
                    maxLines: 5,
                    minLines: 2,
                    enabled: false,
                    cursorColor: Color.fromARGB(255, 252, 139, 26),
                    decoration: new InputDecoration(
                      suffixIcon: Icon(
                        Icons.add_location_alt_outlined,
                        color: Color.fromARGB(255, 252, 139, 26),
                      ),
                      alignLabelWithHint: true,
                      labelText: 'Location',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 104, 104, 104),
                        fontSize: 16,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Color.fromARGB(255, 252, 139, 26),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Color.fromARGB(255, 252, 139, 26),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    right: 30,
                    left: 30,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(5),
                      backgroundColor: Color.fromARGB(255, 252, 139, 26),
                    ),
                    child: Text('Save'),
                    onPressed: editData,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  editData() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final location = locationController.text.trim();

    if (title.isNotEmpty &&
        description.isNotEmpty &&
        location.isNotEmpty &&
        latitude != null &&
        longitude != null &&
        sublocality != null) {
      reminderModel.title = title;
      reminderModel.description = description;
      reminderModel.location = sublocality!;
      reminderModel.latitude = latitude!;
      reminderModel.longitude = longitude!;
      reminderModel.radius = sliderValue.round();
      reminderModel.save();

      Get.back();
    } else {
      Fluttertoast.showToast(
        msg: "All Fields are required",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Color.fromRGBO(107, 107, 107, 1),
        textColor: Color.fromARGB(255, 255, 255, 255),
      );
    }
  }
}
