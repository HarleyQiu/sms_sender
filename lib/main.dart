import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // 用于处理权限请求
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

void main() {
  runApp(MyApp()); // 运行 Flutter 应用
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState(); // 创建状态
}

class _MyAppState extends State<MyApp> {
  SmsQuery query = SmsQuery(); // 初始化SMS查询对象
  List<SmsMessage> messages = []; // 用于存储读取的短信

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (await Permission.sms.request().isGranted) {
      _readSms();
    } else {
      // 处理用户拒绝权限的情况，可能显示一个提示或者关闭应用
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("权限警告"),
            content: const Text("需要短信权限才能读取短信"),
            actions: <Widget>[
              TextButton(
                child: const Text("确定"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // 获取最新短信
  Future<void> _readSms() async {
    try {
      messages = await query
          .querySms(kinds: [SmsQueryKind.inbox, SmsQueryKind.sent], count: 10);
      setState(() {}); // 更新UI

      // 打印读取到的短信内容到控制台
      if (messages.isNotEmpty) {
        print("地址: ${messages[0].address}");
        print("短信内容: ${messages[0].body}");
      } else {
        print("没有收到新短信");
      }
    } catch (e) {
      print('读取短信出错: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("SMS Reader")),
        body: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(messages[index].address ?? 'Unknown'),
              subtitle: Text(messages[index].body ?? 'No Content'),
            );
          },
        ),
      ),
    );
  }
}
