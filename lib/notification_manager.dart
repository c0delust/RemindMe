import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static String channelKey = 'remindme_channel_';
  static final AudioPlayer audioPlayer = AudioPlayer();

  static Future<void> initializeNotification() async {
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: 'Task Notification',
          channelDescription: 'Notification Channel for RemindMe Tasks',
          importance: NotificationImportance.Max,
          enableVibration: true,
          playSound: false,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: channelKey + '_group',
          channelGroupName: 'Group 1',
        ),
      ],
    );

    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await awesomeNotifications.requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final payload = receivedAction.payload ?? {};

    if (payload['close'] == 'true') {
      if (audioPlayer.playing) {
        audioPlayer.stop();
      }
    }
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (audioPlayer.playing) {
      audioPlayer.stop();
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    if (prefs.getBool('notificationKey')!) {
      if (prefs.getStringList('fileKey') != null) {
        if (prefs.getStringList('fileKey')![0] == 'Default') {
          audioPlayer.setAsset('assets/audio/tone.mp3');
          audioPlayer.play();
        } else {
          audioPlayer.setFilePath(prefs.getStringList('fileKey')![0]);
          audioPlayer.play();
        }
      }
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        groupKey: channelKey + '_group',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Inbox,
        payload: {'close': 'true'},
        autoDismissible: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'close',
          label: 'Close',
          actionType: ActionType.DismissAction,
        ),
      ],
    );
  }
}
