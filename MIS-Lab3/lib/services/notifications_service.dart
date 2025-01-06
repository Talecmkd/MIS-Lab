import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mis_lab3/main.dart';
class NotificationsService {
  final _firebaseMessaging = FirebaseMessaging.instance;


  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();

    print('Token:  $fCMToken');

    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message){
    if(message == null) return;

    navigatorKey.currentState?.pushNamed(
      '/notification_screen',
      arguments: message,
    );
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);


    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

}