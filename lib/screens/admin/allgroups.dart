import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:shareacab/models/user.dart';
import 'package:shareacab/screens/groupdetailscreen/groupdetails.dart';
import 'package:shareacab/services/database.dart';
import 'package:shareacab/utils/common.dart';
import 'package:shareacab/utils/constant.dart';

class GroupList extends StatefulWidget {
  final userId;
  GroupList(this.userId);
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
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
          elevation: 0,
          title: Row(children: [
            // Image.asset(
            //   'assets/images/logo_full_qq.png',
            //   width: 160,
            //   height: 22,
            // ),
            Text(
              (widget.userId != null ? '過去加入群組' : '刊登團體'),
              style: TextStyle(
                  color: text_color1,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('group')
                .orderBy('created', descending: true)
                .snapshots(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                Center(child: CircularProgressIndicator());
              }
              var GroupList = <GroupData>[];
              if (snapshot.data != null) {
                for (var i = 0; i < snapshot.data.documents.length; i++) {
                  final doc = snapshot.data.documents[i];
                  var format = DateFormat('yyyy.MM.dd    h:mm a');
                  var createdAt = CommonUtils.convertFBTimeStamp2DateTime(
                      doc.data['created']);
                  var group = GroupData(
                    id: doc.documentID,
                    reference_number: doc.data['reference_number'] ?? '',
                    created: createdAt != null ? format.format(createdAt) : '',
                  );

                  if (widget.userId != null) {
                    var find_user = doc.data['users'].firstWhere(
                        (element) => element['uid'] == widget.userId, orElse: () {
                      return null;
                    });
                    var find_user_out = doc.data['users-out'].firstWhere(
                        (element) => element['uid'] == widget.userId, orElse: () {
                      return null;
                    });

                    if ((find_user != null || find_user_out != null) &&
                        group.reference_number.contains(search)) {
                      GroupList.add(group);
                    }
                  } else {
                    if (group.reference_number.contains(search)) {
                      GroupList.add(group);
                    }
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
                        type: 'text',
                        hint: '請輸入團體ID',
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
                        '共計 : ${GroupList.length}',
                        style: TextStyle(fontSize: 16, color: text_color1),
                      ),
                    ),
                    Expanded(
                        child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: GroupList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            color: Colors.white,
                            elevation: 0.0,
                            margin: EdgeInsets.zero,
                            child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GroupDetails(
                                                GroupList[index].id,
                                                isHistory: true,
                                              )));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color: grey_color5,
                                  ))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                            GroupList[index].reference_number,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: text_color1),
                                          )),
                                      Text(
                                        GroupList[index].created,
                                        style: TextStyle(
                                            fontSize: 16, color: text_color1),
                                      )
                                    ],
                                  ),
                                )));
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                        height: 0,
                      ),
                    ))
                  ],
                ),
              );
            }));
  }
}

class GroupData {
  String id;
  String reference_number;
  String created;
  GroupData({this.id, this.reference_number, this.created});
}
