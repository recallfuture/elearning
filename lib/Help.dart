import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        clipBehavior: Clip.antiAlias,
        color: Colors.blue,
        elevation: 10.0,
        margin: EdgeInsets.all(20.0),
        semanticContainer: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              buildTitle(),
              SizedBox(
                height: 30,
              ),
              buildUsage(),
              SizedBox(
                height: 30,
              ),
              buildAuthor(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      '查作业',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 50.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget buildUsage() {
    return Text(
      '使用方法：\n输入正确的学号和密码即可登录，注意不要输错5次，会导致帐号被锁一天。\n\n' +
          '登录后会自动查询当前还差多少作业没交，软件也会在查询后设定定时通知，' +
          '在作业截至日期前三天和前一天发送通知提醒交作业。\n\n' +
          '登录过的话，下次打开软件会自动登录\n\n',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.white,
      ),
    );
  }

  Widget buildAuthor() {
    return Text(
      '作者：孙旭\n' + 'v1.2',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
    );
  }
}
