import 'package:flutter/material.dart';
import 'package:shareacab/screens/admin/allgroups.dart';
import 'package:shareacab/screens/admin/textsetting.dart';
import 'package:shareacab/screens/admin/userlist.dart';
import 'package:shareacab/utils/constant.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<String> entries = <String>[
    '註冊用戶',
    '刊登團體',
    '最新消息',
    '免責聲明',
    '私隱條例',
    'F&Q問答'
  ];

  void onPressItem(int index) {
    print('press $index');
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return UserList();
      }));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return GroupList();
      }));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TextSetting('news');
      }));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TextSetting('terms');
      }));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TextSetting('policy');
      }));
    } else if (index == 5) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TextSetting('faq');
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: yellow_color2,
          leadingWidth: 32,
          leading: Container(
            padding: EdgeInsets.only(left: 6),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: text_color1,
                size: 32,
              ),
            ),
          ),
          titleSpacing: 8,
          title: Row(children: [
            // Image.asset(
            //   'assets/images/logo_full_qq.png',
            //   width: 160,
            //   height: 22,
            // ),
            Text(
              '管理員',
              style: TextStyle(
                  color: text_color1,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),
        body: ListView.separated(
          padding: EdgeInsets.all(20),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                color: Colors.white,
                elevation: 0.0,
                margin: EdgeInsets.zero,
                child: InkWell(
                    onTap: () {
                      onPressItem(index);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entries[index],
                            style: TextStyle(fontSize: 16, color: text_color1),
                          )
                        ],
                      ),
                    )));
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(
            height: 1,
            color: Color(0x99B3BABF),
          ),
        ));
  }
}
