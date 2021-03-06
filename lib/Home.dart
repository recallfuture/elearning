import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import './School.dart';
import './LocalNotification.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 课程
  Map<String, String> _courses;
  // 课程名为键，待交作业列表为值
  // 待交作业列表由作业的信息map组成
  Map<String, List<Map<String, String>>> _allHomeworks = Map();

  @override
  void initState() {
    super.initState();

    School.instance.getReminder().then((courses) async {
      setState(() {
        _courses = courses;
      });
      // FIXED: 异步同时请求会无法获得正确的课程信息，需要同步执行
      for (var courseId in courses.keys) {
        String courseName = courses[courseId];

        List<List<String>> course = await School.instance.getCourse(courseId);
        for (List<String> c in course) {
          // 获取交付时间
          DateTime date;
          if (c[1] != null) {
            date = DateTime.parse(c[1]);
          }

          // 还没提交且还没到期的
          if (c[6] == null &&
              date.millisecondsSinceEpoch >
                  DateTime.now().millisecondsSinceEpoch) {
            // 获取作业内容
            String homeworkId = School.instance.getHomeworkId(c[4]);
            String content =
                await School.instance.getHomeworkContent(homeworkId);
            print(content);

            // 添加作业信息
            Map<String, String> homework = Map();
            homework['date'] = c[1];
            homework['title'] = c[0];
            homework['content'] = content;

            if (_allHomeworks[courseName] == null) {
              _allHomeworks[courseName] = List();
            }
            setState(() {
              _allHomeworks[courseName].add(homework);
            });
            // 在交作业前一天给个提醒
            // 当前时间已经超过的话就不重复提醒了
            if(date.add(Duration(hours: -18)).isAfter(DateTime.now())) {
              LocalNotification.instance.schedule(
                  date.add(Duration(hours: -18)),
                  '[$courseName]的作业明天要交啦！',
                  '作业名：${homework['title']}，截止日期：${date.year}年${date
                      .month}月${date.day}日。');
            }
            // 在交作业前三天给提个醒
            // 当前时间已经超过的话就不重复提醒了
            if(date.add(Duration(days: -2, hours: -18)).isAfter(DateTime.now())) {
              LocalNotification.instance.schedule(
                  date.add(Duration(days: -2, hours: -18)),
                  '该写[$courseName]的作业啦',
                  '作业名：${homework['title']}，截止日期：${date.year}年${date.month}月${date.day}日。');
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listItems = List();
    listItems.add(buildCard());
    listItems.addAll(buildHomeworkList(context));

    return Scaffold(
        body: ListView(padding: EdgeInsets.all(20.0), children: listItems));
  }

  // 提示框
  Widget buildCard() {
    return (_courses?.length ?? 0) > 0
        ? ReminderCard(
            icon: const Icon(
              Icons.error,
              color: Colors.white,
              size: 40.0,
            ),
            color: Colors.redAccent,
            content: '${_courses.length}门课程有待交作业',
          )
        : ReminderCard(
            icon: const Icon(
              Icons.info,
              color: Colors.white,
              size: 40.0,
            ),
            color: Colors.greenAccent,
            content: '无待交作业，安心休息吧',
          );
  }

  void showHomeworkDialog(BuildContext context,String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(padding: EdgeInsets.all(20.0),
            child: ListView(children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Html(
                data: content,
                useRichText: true,
                padding: EdgeInsets.all(8.0),
                defaultTextStyle: TextStyle(fontSize: 20.0),
              ),
            ]),
          ),
        );
      },
    );
  }

  // 待交作业列表
  List<Widget> buildHomeworkList(BuildContext context) {
    List<Widget> list = List();
    // _allHomeworks是多个科目的列表
    _allHomeworks.forEach((courseName, homeworks) {
      print(courseName);
      list.add(Text(courseName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          )));

      // homeworks是单个科目的作业列表
      // homework是单个作业的信息字典
      homeworks.forEach((homework) {
        DateTime date = DateTime.parse(homework['date']);

        list.add(Card(
          elevation: 5.0,
          margin: EdgeInsets.all(20.0),
          child: ListTile(
            title: Text(
              homework['title'],
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              '${date.year}年${date.month}月${date.day}日',
              textAlign: TextAlign.center,
            ),
            onTap: () {
              showHomeworkDialog(context, homework['title'] , homework['content']);
            },
          ),
        ));
      });
    });
    return list;
  }
}

class ReminderCard extends StatelessWidget {
  final Icon icon;
  final Color color;
  final String content;

  ReminderCard({this.icon, this.color, this.content}) : super();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: color,
      elevation: 20.0,
      margin: EdgeInsets.all(20.0),
      semanticContainer: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: ListTile(
        leading: icon,
        title: Text(
          content,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        contentPadding: EdgeInsets.all(20.0),
      ),
    );
  }
}
