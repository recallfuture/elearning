import 'package:flutter/material.dart';
import './School.dart';
import './Pair.dart';
import './LocalNotification.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 课程
  Map<String, String> _courses;
  // 课程名为键，待交作业列表为值
  Map<String, List<Pair<String, DateTime>>> _homeworks = Map();

  @override
  void initState() {
    super.initState();

    
    School.instance.getReminder().then((courses) {
      setState(() {
        _courses = courses;
      });
      courses.forEach((courseId, courseName) {
        School.instance.getCourse(courseId).then((course) {
          for(List<String> c in course){
            // 获取交付时间
            DateTime date;
            if(c[1] != null){
              date = DateTime.parse(c[1]);
            }

            // 还没提交且还没到期的
            if(c[6] == null && date.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
              Pair<String, DateTime> homework = Pair(c[0], date);
              if(_homeworks[courseName] == null) {
                _homeworks[courseName] = List();
              }
              setState(() {
                _homeworks[courseName].add(homework);
              });
              // 在交作业前一天给个提醒
              LocalNotification.instance.schedule(
                  date.add(Duration(hours: -18)),
                  '$courseName有作业明天要交啦',
                  '作业名：${homework.first}\n截止日期：${date.year}年${date.month}月${date.day}日'
              );
              // 在交作业前三天给提个醒
              LocalNotification.instance.schedule(
                  date.add(Duration(days: -2, hours: -18)),
                  '$courseName有作业就快要交啦',
                  '作业名：${homework.first}\n截止日期：${date.year}年${date.month}月${date.day}日'
              );
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listItems = List();
    listItems.add(buildCard());
    listItems.addAll(buildHomeworkList());

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: listItems
      )
    );
  }

  // 提示框
  Widget buildCard() {
    return (_courses?.length ?? 0) > 0
        ?
    ReminderCard(
      icon: const Icon(Icons.error, color: Colors.white, size: 40.0,),
      color: Colors.redAccent,
      content: '有${_courses.length}门课程有待交作业',
    )
        :
    ReminderCard(
      icon: const Icon(Icons.info, color: Colors.white, size: 40.0,),
      color: Colors.greenAccent,
      content: '无待交作业，安心休息吧',
    );
  }

  // 待交作业列表
  List<Widget> buildHomeworkList() {
    List<Widget> list = List();
    _homeworks.forEach((courseName, homework) {
      print(courseName);
      list.add(ListTile(
        title: Text(
          courseName,
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));

      homework.forEach((item) {
        print(item.first);
        list.add(
          ListTile(
            leading: Text('${item.second.year}年${item.second.month}月${item.second.day}日'),
            title: Text(item.first),
          )
        );
      });
    });
    return list;
  }
}

class ReminderCard extends StatelessWidget {
  final Icon icon;
  final Color color;
  final String content;
  
  ReminderCard({this.icon, this.color, this.content}): super();
  
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: color,
      elevation: 20.0,
      margin: EdgeInsets.all(20.0),
      semanticContainer: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
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