import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mis_lab3/screens/notification_screen.dart';
import 'package:mis_lab3/services/notifications_service.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';


final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationsService().initNotifications();
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '211034',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      navigatorKey: navigatorKey,
      routes: {
        '/notification_screen': (context) => const NotificationScreen(),
      }
    );
  }
}
