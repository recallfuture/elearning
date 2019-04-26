import 'package:flutter/material.dart';
import './School.dart';
import './Login.dart';
import './Home.dart';
import './Help.dart';
import './LocalNotification.dart';

void main() async {
  School.instance = new School();
  await School.instance.init();

  LocalNotification.instance = new LocalNotification();
  await LocalNotification.instance.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '查作业',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: LoginPage(),
      ),
      routes: <String, WidgetBuilder> {
        // 这里可以定义静态路由，不能传递参数
        '/home': (_) => HomePage(),
        '/help': (_) => HelpPage()
      },
    );
  }
}
