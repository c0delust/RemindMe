import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remindme/main.dart';
import 'package:remindme/models/reminder_model.dart';
import 'package:remindme/screens/maps_screen.dart';
import '../widgets/radius_slider.dart';

// ignore: must_be_immutable
class AddReminder extends StatelessWidget {
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

  void navigateToMapsScreen() {
    titleFocusNode.unfocus();
    descriptionFocusNode.unfocus();
    Map<String, dynamic> arguments = {'radius': sliderValue};

    if (latitude != null && longitude != null && sublocality != null) {
      arguments = {
        'LatLng': LatLng(latitude!, longitude!),
        'radius': sliderValue,
        'sublocality': sublocality,
      };
    }

    Get.to(() => mapsScreen,
            transition: Transition.rightToLeft, arguments: arguments)!
        .then((value) {
      if (value != null) {
        locationController.text =
            "${value['sublocality']}\nLatitude: ${value['latitude']}\nLongitude: ${value['longitude']}";
        sublocality = value['sublocality'];
        latitude = value['latitude'];
        longitude = value['longitude'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        title: Text('Add'),
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
                    navigateToMapsScreen();
                  },
                  child: TextField(
                    style: TextStyle(fontSize: 15, color: Colors.black),
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
                      labelText: 'Location ',
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
                    onPressed: saveData,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  saveData() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final location = locationController.text.trim();
    print('$location $latitude $longitude');
    if (title.isNotEmpty &&
        description.isNotEmpty &&
        location.isNotEmpty &&
        latitude != null &&
        longitude != null &&
        sublocality != null) {
      final data = ReminderModel(title, description, sublocality!, latitude!,
          longitude!, sliderValue.round(), false, true);
      MyApp.reminderBox.add(data);
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
