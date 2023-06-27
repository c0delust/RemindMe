import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  RxBool backgroundValue = true.obs;
  RxBool notificationValue = false.obs;
  String filePath = '';
  RxString fileName = ''.obs;

  late SharedPreferences prefs;

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    notificationValue.value = prefs.getBool('notificationKey')!;
    filePath = prefs.getStringList('fileKey')![0];
    fileName.value = prefs.getStringList('fileKey')![1];
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      filePath = file.path!;
      fileName.value = file.name;

      await prefs.setStringList('fileKey', [file.path!, file.name]);
      prefs.reload();

      print('File Path: ' + file.path!);
    } else {
      // User canceled the picker
    }
  }

  setDefault() async {
    await prefs.setBool('notificationKey', true);
    await prefs.setStringList('fileKey', ['Default', 'Default']);
    prefs.reload();

    notificationValue.value = true;
    filePath = '';
    fileName.value = 'Default';
  }

  @override
  Widget build(BuildContext context) {
    getSharedPreferences();

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            OutlinedButton(
              onPressed: () async {
                bool isRunning = await serviceBackground.isRunning();
                if (isRunning) {
                  await serviceBackground.startService();
                  serviceBackground.invoke('stopService');

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Background process canceled successfully!'),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                primary: Colors.red,
                side: BorderSide(
                  color: Colors.red,
                ),
              ),
              child: Text(
                'Cancel Background Process',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notification Sound'),
                Obx(
                  () => Switch(
                    activeColor: Color.fromARGB(255, 252, 139, 26),
                    value: notificationValue.value,
                    onChanged: (value) async {
                      notificationValue.value = value;
                      await prefs.setBool('notificationKey', value);
                      prefs.reload();
                    },
                  ),
                ),
              ],
            ),
            Divider(),
            InkWell(
              onTap: () {
                pickFile();
              },
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text('Sound'),
                subtitle: Obx(() => Text(fileName.value)),
                trailing: Container(
                    margin: EdgeInsets.only(
                      right: 15,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Color.fromARGB(255, 252, 139, 26),
                    )),
              ),
            ),
            Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => setDefault(),
                  child: Text(
                    'Default',
                    style: TextStyle(
                      color: Color.fromARGB(255, 252, 139, 26),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
