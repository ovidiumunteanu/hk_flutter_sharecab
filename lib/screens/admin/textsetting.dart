import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/models/user.dart';
import 'package:shareacab/services/database.dart';
import 'package:shareacab/utils/constant.dart';

class TextSetting extends StatefulWidget {
  @override
  _TextSettingState createState() => _TextSettingState();
}

class _TextSettingState extends State<TextSetting> {
  var isLoading = false;
  var page = 1;
  var scrollcontroller = ScrollController();
  String search = '';
  bool isSwitched = false;

  @override
  void initState() {
    //added the pagination function with listener
    scrollcontroller.addListener(pagination);
    super.initState();
  }

  void pagination() {
    // if ((scrollcontroller.position.pixels ==
    //     scrollcontroller.position.maxScrollExtent) && (_subCategoryModel.products.length < total)) {
    //   setState(() {
    //     isLoading = true;
    //     page += 1;
    //     //add api for load the more data according to new page
    //   });
    // }
  }

  void toggleSwitch(String userId, bool value) {
    DatabaseService().blockUser(userid: userId, flag: !value);
  }

  void onPressItem(int index) {
    print('press $index');
    if (index == 0) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) {
      //   return TextSetting();
      // }));
    } else if (index == 1) {
    } else if (index == 2) {
    } else if (index == 3) {
    } else if (index == 4) {}
  }

  void onSave() async { 

  }

  @override
  Widget build(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width;
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
              '註冊用戶',
              style: TextStyle(
                  color: text_color1,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('settings')
                .snapshots(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                Center(child: CircularProgressIndicator());
              }
              List<Userdetails> TextSetting = [];
              final count = snapshot.data == null
                  ? 0
                  : snapshot.data.documents.length;
              if (snapshot.data != null) {
                for (var i = 0; i < snapshot.data.documents.length; i++) {
                  final doc = snapshot.data.documents[i];
                  var userDetails = Userdetails(
                    uid: doc.documentID,
                    name: doc.data['name'] ?? '',
                    email: doc.data['email'] ?? '',
                    mobilenum: doc.data['mobileNumber'] ?? '',
                    isBlocked: doc.data['isBlocked'] ?? false,
                  );
                  if (userDetails.mobilenum.contains(search)) {
                    TextSetting.add(userDetails);
                  }
                }
              }
              return Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            color: Color(0xFFf7f7f7),
                            child: TextFormField(
                                minLines: 15,
                                maxLines: 40,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: text_color1),
                                decoration: InputDecoration(
                                    hintText: '請輸入內容',
                                    hintStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFBBBBBB)),
                                    border: InputBorder.none),
                                onChanged: (val) {}),
                          )),
                    ),
                    Container(
                      width: double.infinity,
                      child: FlatButton(
                        color: yellow_color1,
                        onPressed: onSave,
                        height: 60,
                        child: Text(
                          '確認', // You are in a group and viewing a private group
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: text_color2),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }));
  }
}
