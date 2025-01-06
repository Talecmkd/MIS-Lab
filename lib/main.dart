import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/exam_provider.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExamProvider(),
      child: MaterialApp(
        title: 'Exam Schedule',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CalendarScreen(),
      ),
    );
  }
}