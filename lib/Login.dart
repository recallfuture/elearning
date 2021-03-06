/*
 * 修改自: https://github.com/lizhuoyuan/flutter_study/blob/master/lib/login_page.dart
 */

import 'package:flutter/material.dart';
import './School.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  FocusNode passwordFieldNode = FocusNode();
  String _username, _password;
  bool _isObscure = true;
  Color _eyeColor;
  bool _logining = false;

  @override
  void initState() {
    super.initState();

    // 检查是否有用户名和密码
    this._username = School.instance.getUsername();
    this._password = School.instance.getPassword();

    // 存在的话就直接登录
    if (!(this._username == null || this._password == null)) {
      login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 22.0),
          children: <Widget>[
            SizedBox(height: 50.0),
            SizedBox(
              height: kToolbarHeight,
            ),
            buildTitle(),
            SizedBox(height: 100.0),
            buildUsernameTextField(context),
            SizedBox(height: 30.0),
            buildPasswordTextField(context),
            SizedBox(height: 100.0),
            buildLoginButton(context),
            SizedBox(
              height: 50.0,
            ),
            buildHelp(context),
          ],
        ));
  }

  // 登录
  void login() {
    setState(() {
      this._logining = true;
    });

    // 获取登录状态
    School.instance.login().then((int loginStatus) {
      setState(() {
        this._logining = false;
      });
      if (loginStatus == 200) {
        // Scaffold.of(context).showSnackBar(SnackBar(content: new Text('登录成功')));
        // 进入主页面
        Navigator.of(context).pushNamed('/home');
      } else {
        if (loginStatus == 400) {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: new Text('登录失败，请检查学号和密码')));
        } else if (loginStatus == 401) {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: new Text('登录失败，无法获取token')));
        } else if (loginStatus == 403) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: new Text('您已登录失败5次，账号被锁定，请您明天再试！')));
        }
      }
    }).catchError((e) {
      setState(() {
        this._logining = false;
      });
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: new Text('发生了错误，请检查网络并重试')));
    });
  }

  // 提交表单
  void submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (this._logining) {
        return;
      }

      // 保存账号和密码
      School.instance.setUsername(this._username);
      School.instance.setPassword(this._password);

      login();
    }
  }

  Align buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: RaisedButton(
          child: _logining
              ? CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  '登录',
                  style: Theme.of(context).primaryTextTheme.headline,
                ),
          color: Colors.black,
          onPressed: () => submit(),
          shape: StadiumBorder(side: BorderSide()),
        ),
      ),
    );
  }

  TextFormField buildPasswordTextField(BuildContext context) {
    return TextFormField(
      focusNode: passwordFieldNode,
      initialValue: this._password,
      onSaved: (String value) => _password = value,
      obscureText: _isObscure,
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入密码';
        }
      },
      decoration: InputDecoration(
          labelText: '请输入密码',
          suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = _isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color;
                });
              })),
      onEditingComplete: () => submit(),
    );
  }

  TextFormField buildUsernameTextField(BuildContext context) {
    return TextFormField(
      initialValue: this._username,
      decoration: InputDecoration(
        labelText: '请输入学号/工号',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return '请输入学号/工号';
        }
      },
      onSaved: (String value) => _username = value,
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(passwordFieldNode),
    );
  }

  Padding buildTitle() {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  color: Colors.black,
                  width: 5.0,
                  height: 50.0,
                ),
              ),
            ),
            Text(
              '教学平台登录',
              style: TextStyle(fontSize: 40.0),
            ),
          ],
        ));
  }

  Widget buildHelp(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: IconButton(
        iconSize: 40.0,
        icon: Icon(
          Icons.help,
          color: Colors.blue,
        ),
        onPressed: () => Navigator.of(context).pushNamed('/help'),
      ),
    );
  }
}
