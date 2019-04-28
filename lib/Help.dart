import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          padding: EdgeInsets.all(30.0),
          child: ListView(
            children: <Widget>[
              buildTitle(),
              buildUsage(),
              buildAuthor(),
              Builder(builder: (BuildContext context) {
                return buildGithub(context);
              }),
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
        fontSize: 40.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget buildUsage() {
    return Text(
      'v1.3\n\n' +
      '使用方法：\n输入正确的学号和密码即可登录，注意不要输错5次，会导致帐号被锁一天。\n\n' +
          '登录后会自动查询当前还差多少作业没交，软件也会在查询后设定定时通知，' +
          '在作业截至日期前三天和前一天发送通知提醒交作业。\n\n' +
          '登录过的话，下次打开软件会自动登录\n',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.white,
      ),
    );
  }

  Widget buildAuthor() {
    return Text(
      '作者：孙旭\n' +
      '项目已在Github开源',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
    );
  }

  Widget buildGithub(BuildContext context) {
    return FlatButton(
        onPressed: () async {
          const url = 'https://github.com/recallfuture/elearning';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: new Text('浏览器启动失败')));
          }
        },
        child: Text(
          'https://github.com/recallfuture/elearning',
          textAlign: TextAlign.center,
          style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),),
    );
  }
}
