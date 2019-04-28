import 'package:dio/dio.dart';
import 'dart:io';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class School {
  String _username;
  String _password;

  Dio _dio;
  SharedPreferences _prefs;
  CookieJar _cookieJar = CookieJar();

  static School instance;

  // 获取用户名和密码
  String getUsername() {
    _username = _prefs.getString('username');
    return _username;
  }

  String getPassword() {
    _password = _prefs.getString('password');
    return _password;
  }

  void setUsername(String username) async {
    _username = username;
    await _prefs.setString('username', username);
  }

  void setPassword(String password) async {
    _password = password;
    await _prefs.setString('password', password);
  }

  // 添加默认配置
  void addOptions() {
    _dio.options.baseUrl = 'http://elearning.ncst.edu.cn/meol/';
    _dio.options.headers = {
      'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding': 'gzip',
      'Accept-Language': 'zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4'
    };
    _dio.options.contentType =
        ContentType.parse("application/x-www-form-urlencoded");
    // 任意HTTP响应码均不报错
    _dio.options.validateStatus = (code) => true;
  }

  Future<void> init() async {
    // 初始化
    _dio = Dio();
    addOptions();

    // 添加cookie和日志的拦截器
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(LogInterceptor(responseBody: false));

    // 获取本地存储实例
    _prefs = await SharedPreferences.getInstance();
  }

  // 用get方式获取url指向的的内容
  Future<String> getContent(String url) async {
    // 获取字节流并转换成gbk编码的文本
    Response<List<int>> response = await _dio.get<List<int>>(
      url,
      options: Options(
          responseType: ResponseType.bytes
      ),
    );
    return gbk.decode(response.data);
  }

  // 获取第一个正则匹配内容
  Match matchOne(String regex, String content) {
    RegExp exp = RegExp(regex);
    return exp.firstMatch(content);
  }

  // 获取所有正则匹配内容
  Iterable<Match> matchAll(String regex, String content) {
    RegExp exp = RegExp(regex);
    return exp.allMatches(content);
  }

  // 登录
  // 返回是否登录成功
  // 200为成功
  // 400为帐号或密码错误
  // 401为帐号为token错误
  // 403为帐号被锁，无权进入
  Future<int> login() async {
    if (_username == null || _password == null) {
      return 400;
    }

    // 获取csrf token
    String token;
    String content = await getContent('loginCheck.do');
    Match match = matchOne(
        r'<input type="hidden" name="logintoken" value="(\d+)"/>', content);
    if (match != null) {
      token = match.group(1);
      print('token: ' + token);
    } else {
      return 401;
    }

    // 登录表单数据
    FormData formData = FormData.from({
      'logintoken': token,
      'enterLid': '',
      'IPT_LOGINUSERNAME': _username,
      'IPT_LOGINPASSWORD': _password,
    });

    // 提交登录表单
    Response<List<int>> response = await _dio.post<List<int>>(
      'loginCheck.do',
      data: formData,
      options: Options(
        responseType: ResponseType.bytes
      ),
    );

    // 重定向意味着成功登录了
    if (response.statusCode == 302) {
      // 登录成功
      return 200;
    } else {
      // 转码
      String content = gbk.decode(response.data);
      print(content);

      // 检查是否是帐号密码错误
      Match match = matchOne(r'用户名或密码错误！', content);
      if(match != null) {
        return 400;
      }

      // 检查是否被锁帐号了
      match = matchOne(r'您已登录失败5次，账号被锁定，请您明天再试！', content);
      if(match != null) {
        return 403;
      }

      return 400;
    }
  }

  // 获取待交作业的提示信息和课程地址
  // 返回由课程号和课程名组成的map
  Future<Map<String, String>> getReminder() async {
    Map<String, String> reminder = new Map();

    String content =
        await getContent('welcomepage/student/interaction_reminder_v8.jsp');
    Iterable<Match> matchs = matchAll(
        r'<a href="./lesson/enter_course.jsp\?lid=(\d+)&t=hw" target="_blank">(.+?)</a></li>',
        content);
    for (Match m in matchs) {
      reminder[m.group(1).trim()] = m.group(2).trim();
      print('${m.group(2).trim()}: ${m.group(1)}');
    }

    return reminder;
  }

  // 获取课程作业信息
  // 返回每项作业的详细信息列表
  Future<List<List<String>>> getCourse(String courseId) async {
    List<List<String>> course = new List();

    // 需要先访问这个课程地址才能通过下面的固定地址得到正确的作业信息
    await getContent('jpk/course/layout/newpage/index.jsp?courseId=$courseId');
    String content = await getContent(
        'http://elearning.ncst.edu.cn/meol/common/hw/student/hwtask.jsp');

    // 获取表格的行
    Iterable<Match> rows = matchAll(r'<tr>((?:.|\n)*?)</tr>', content);
    for (Match r in rows) {
      // 获取表格的列
      Iterable<Match> cols = matchAll(r'<td.*?>((?:.|\n)*?)</td>', r.group(1));
      // 长度小于0时是表格头，大于0时是内容
      if (cols.length > 0) {
        List<String> col = new List();
        for (Match c in cols) {
          col.add(c.group(1));
        }

        // 处理每列的信息
        print('作业信息');
        Match m;

        // 匹配作业名
        m = matchOne(r'<a.*?>(\S+)(?:.|\n)*?</a>', col[0]);
        if (m != null) {
          col[0] = m.group(1);
        } else {
          col[0] = null;
        }
        print(col[0]);

        // 匹配日期
        Iterable<Match> ms = matchAll(r'(\d+)', col[1]);
        var ml = ms.toList();
        if (ml.length > 0) {
          int year = int.parse(ml[0].group(1));
          int month = int.parse(ml[1].group(1));
          int day = int.parse(ml[2].group(1));
          col[1] = DateTime(year, month, day).toString();
        } else {
          col[1] = null;
        }
        print(col[1]);

        // 匹配分数
        m = matchOne(r'(\S+)', col[2]);
        if (m != null) {
          col[2] = m.group(1);
        } else {
          col[2] = null;
        }
        print(col[2]);

        // 匹配发布人
        m = matchOne(r'(\S+)', col[3]);
        if (m != null) {
          col[3] = m.group(1);
        } else {
          col[3] = null;
        }
        print(col[3]);

        // 匹配统计信息
        m = matchOne(r'href="../(.+?)"', col[4]);
        if (m != null) {
          col[4] = 'common/hw/${m.group(1)}';
        } else {
          col[4] = null;
        }
        print(col[4]);

        // 匹配提交作业
        m = matchOne(r'href="(.+?)"', col[5]);
        if (m != null) {
          col[5] = 'common/hw/student/${m.group(1)}';
        } else {
          col[5] = null;
        }
        print(col[5]);

        // 匹配查看结果
        m = matchOne(r'href="(.+?)"', col[6]);
        if (m != null) {
          col[6] = 'common/hw/student/${m.group(1)}';
        } else {
          col[6] = null;
        }
        print(col[6]);

        // 优秀作品（没啥用就不匹配了）
        col[7] = null;
        print(col[7]);

        // 存入课程信息
        course.add(col);
      }
    }

    return course;
  }

  // 从统计信息url中获得作业id
  String getHomeworkId(String statUrl) {
    return matchOne(r'hwtid=(\d+)', statUrl)?.group(1);
  }

  // 获取作业信息
  // 格式是html文本
  Future<String> getHomeworkContent(String homeworkId) async {
    if (homeworkId == null) {
      return null;
    }

    String content =
        await getContent('common/hw/student/hwtask.view.jsp?hwtid=$homeworkId');
    Match match = matchOne(r"<input type='hidden'.*?value='(.*?)'>", content);
    if (match != null) {
      String html = match.group(1);
      html = html.replaceAll(RegExp(r'&lt;'), '<');
      html = html.replaceAll(RegExp(r'&gt;'), '>');
      html = html.replaceAll(RegExp(r'&quot;'), '"');
      html = html.replaceAll(RegExp(r'&amp;'), '&');
      return html;
    }

    return null;
  }
}
