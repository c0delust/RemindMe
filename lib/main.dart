import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remindme/background_location_service.dart';
import 'package:remindme/controller/get_controller.dart';
import 'package:remindme/models/reminder_model.dart';
import 'package:remindme/screens/add_reminder_screen.dart';
import 'package:remindme/screens/archive_screen.dart';
import 'package:remindme/screens/home_screen.dart';
import 'package:remindme/screens/settings_screen.dart';
import 'package:remindme/tutorial_screens/screen_1.dart';
import 'package:remindme/widgets/bottom_nav_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final serviceBackground = FlutterBackgroundService();

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderModelAdapter());
  await Hive.openBox<ReminderModel>('reminderBox');

  WidgetsFlutterBinding.ensureInitialized();
  // initSharedPreferences();
  // checkLocationPermission();

  runApp(MyApp());
}

initSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('notificationKey') == null) {
    await prefs.setBool('notificationKey', true);
  }

  if (prefs.getStringList('fileKey') == null) {
    await prefs.setStringList('fileKey', ['Default', 'Default']);
  }
}

checkLocationPermission(BuildContext context) async {
  var perm1 = await Permission.locationWhenInUse.request();

  if (perm1.isDenied) {
    print('locationWhenInUse Denied');
  }

  var perm2 = await Permission.locationAlways.request();

  if (perm2.isDenied) {
    print('locationAlways Denied');
  }

  var perm3 = await Permission.notification.request();

  if (perm3.isDenied) {
    print('notification Denied');
  }

  if (perm1.isPermanentlyDenied ||
      perm2.isPermanentlyDenied ||
      perm3.isPermanentlyDenied) {
    print('Permissions Permanently Denied');
    openAppSettings();
  }

  if (perm1.isGranted && perm2.isGranted) {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isServiceEnabled) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              title: Text('Location Service not enabled!'),
              content: Image.asset(
                'assets/images/location_service.jpg',
                height: 150,
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Geolocator.openLocationSettings();
                      Future.delayed(
                        Duration(seconds: 10),
                        () => initializeService(),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Enable Location Service'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      if (await serviceBackground.isRunning() != true)
        initializeService();
      else
        print('Service is already running.');
    }
  }
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  static Box<ReminderModel> reminderBox =
      Hive.box<ReminderModel>('reminderBox');

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isFirstLaunch') == null) {
      await prefs.setBool('isFirstLaunch', false);
      await prefs.reload();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    MyApp.reminderBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RemindMe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: isFirstLaunch() ? Screen1() : MyHomePage(),
      home: FutureBuilder(
        future: isFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          if (snapshot.hasData) {
            bool isFirstLaunch = snapshot.data as bool;
            if (isFirstLaunch)
              return Screen1();
            else
              return MyHomePage();
          }
          return Text('error');
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final controller = Get.put(Get_Controller());

  List<Widget> screens = [
    HomeScreen(),
    ArchiveScreen(),
    SettingsScreen(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  var unFocusedColor = Color.fromARGB(255, 103, 103, 103);

  @override
  Widget build(BuildContext context) {
    checkLocationPermission(context);
    initSharedPreferences();

    return Scaffold(
      appBar: AppBar(
        actions: [
          Obx(() {
            if (controller.currentIndex.value == 0) {
              return IconButton(
                splashRadius: 25,
                splashColor: Color.fromRGBO(252, 81, 29, 0.3),
                onPressed: () {
                  Get.to(
                    () => AddReminder(),
                    transition: Transition.downToUp,
                  );
                },
                icon: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: 30,
                      shadows: <Shadow>[
                        Shadow(
                            color: Color.fromRGBO(160, 37, 0, 1),
                            blurRadius: 50.0)
                      ],
                    ),
                  ],
                ),
              );
            }
            if (controller.currentIndex.value == 2) {
              return IconButton(
                splashRadius: 25,
                splashColor: Color.fromRGBO(252, 81, 29, 0.3),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Center(
                        child: Container(
                          child: AlertDialog(
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Close',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color.fromARGB(255, 252, 139, 26)),
                                ),
                              ),
                            ],
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Developed by: ',
                                  ),
                                  Text(
                                    'Mohammadsaad Mulla',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      await launchUrl(
                                        Uri.parse(
                                            'https://www.github.com/c0delust'),
                                      );
                                    },
                                    child: Text(
                                      'www.github.com/c0delust',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.blue),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: Row(
                  children: [
                    Icon(
                      Icons.info,
                      // size: 30,
                    ),
                  ],
                ),
              );
            }
            return Text('');
          }),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        title: Text('RemindMe'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(252, 81, 29, 1),
                Color.fromRGBO(248, 181, 51, 1),
              ],
            ),
          ),
        ),
      ),
      body: Obx(
        () => PageStorage(
          bucket: bucket,
          child: screens[controller.currentIndex.value],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Color.fromRGBO(252, 81, 29, 1),
                Color.fromRGBO(248, 181, 51, 1),
              ],
            ),
          ),
          padding: const EdgeInsets.only(right: 0, left: 0, top: 5, bottom: 5),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BottomNavButton(
                text: 'Home',
                icon: Icons.home,
                value: 0,
              ),
              BottomNavButton(
                text: 'Archive',
                icon: Icons.archive,
                value: 1,
              ),
              BottomNavButton(
                text: 'Settings',
                icon: Icons.settings,
                value: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
