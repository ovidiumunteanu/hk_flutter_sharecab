import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/models/user.dart';
import 'package:shareacab/services/database.dart';
import 'package:shareacab/utils/constant.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
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
      //   return UserList();
      // }));
    } else if (index == 1) {
    } else if (index == 2) {
    } else if (index == 3) {
    } else if (index == 4) {}
  }

  // Stream<DocumentSnapshot> getStream(){
  //   .where('title', '>=', term).where('title', '<=', term + '~');
  // }

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
          elevation: 0,
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
                .collection('userdetails')
                .where('isAdmin', isEqualTo: false)
                .orderBy('created', descending: true)
                .snapshots(),
            builder: (_, usersnapshot) {
              if (usersnapshot.connectionState == ConnectionState.waiting) {
                Center(child: CircularProgressIndicator());
              }
              List<Userdetails> userList = [];
              final count = usersnapshot.data == null
                  ? 0
                  : usersnapshot.data.documents.length;
              if (usersnapshot.data != null) {
                for (var i = 0; i < usersnapshot.data.documents.length; i++) {
                  final doc = usersnapshot.data.documents[i];
                  var userDetails = Userdetails(
                    uid: doc.documentID,
                    name: doc.data['name'] ?? '',
                    email: doc.data['email'] ?? '',
                    mobilenum: doc.data['mobileNumber'] ?? '',
                    isBlocked: doc.data['isBlocked'] ?? false,
                  );
                  if (userDetails.mobilenum.contains(search)) {
                    userList.add(userDetails);
                  }
                }
              }
              return Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: SearchInput(
                        type: 'phone',
                        hint: '請輸入電話號碼',
                        onChange: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '共計 : ${userList.length}',
                        style: TextStyle(fontSize: 16, color: text_color1),
                      ),
                    ),
                    Expanded(
                        child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: userList.length,
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          flex: 5,
                                          child: Text(
                                            userList[index].name,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: text_color1),
                                          )),
                                      Expanded(
                                          flex: 5,
                                          child: Text(
                                            (userList[index].mobilenum != null
                                                ? userList[index]
                                                    .mobilenum
                                                    .substring(4)
                                                : ''),
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: text_color1),
                                          )),
                                      Switch(
                                        onChanged: (bool value) {
                                          toggleSwitch(
                                              userList[index].uid, value);
                                        },
                                        value:
                                            userList[index].isBlocked != true,
                                        activeColor: yellow_color1,
                                        activeTrackColor: grey_color6,
                                        inactiveThumbColor: grey_color4,
                                        inactiveTrackColor: grey_color6,
                                      )
                                    ],
                                  ),
                                )));
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                        height: 1,
                        color: Color(0x99B3BABF),
                      ),
                    ))
                  ],
                ),
              );
            }));
  }
}
