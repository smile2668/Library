import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging;

  NotificationService(this._messaging);

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.getToken();
  }

  Stream<RemoteMessage> get foregroundMessages => FirebaseMessaging.onMessage;
}
