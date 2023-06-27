import 'package:hive/hive.dart';
part 'reminder_model.g.dart';

//flutter packages pub run build_runner build --delete-conflicting-outputs
@HiveType(typeId: 0)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  String description;
  @HiveField(2)
  String location;
  @HiveField(3)
  double latitude;
  @HiveField(4)
  double longitude;
  @HiveField(6)
  int radius;
  @HiveField(7)
  bool isDone;
  @HiveField(8)
  bool isEnabled;

  ReminderModel(this.title, this.description, this.location, this.latitude,
      this.longitude, this.radius, this.isDone, this.isEnabled);
}
