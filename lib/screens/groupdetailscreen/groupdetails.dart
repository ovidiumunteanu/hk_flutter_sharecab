import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/screens/groupdetailscreen/mapview.dart';
import 'package:shareacab/services/database.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shareacab/services/trips.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shareacab/screens/chatscreen/chat_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:shareacab/shared/guest.dart';
import 'package:shareacab/utils/constant.dart';
import 'package:shareacab/components/TripItem.dart';
import 'package:shareacab/screens/notifications/services/notifservices.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/utils/global.dart';

class AddNewJoinNum extends StatefulWidget {
  final Function onJoin;
  final List<String> items;

  AddNewJoinNum(this.items, this.onJoin);

  @override
  _AddNewJoinNumState createState() => _AddNewJoinNumState();
}

class _AddNewJoinNumState extends State<AddNewJoinNum> {
  int newJoiningMember = 1;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: Text('加入组'),
      content: Container(
        height: 120,
        child: Column(
          children: [
            Text('您有多少人加入此群組？'),
            SizedBox(height: 20),
            DropdownInput(
              label: ' ',
              curItem: newJoiningMember.toString(),
              items: widget.items,
              onChange: (newValue) {
                setState(() => newJoiningMember = int.parse(newValue));
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('取消',
              style: TextStyle(color: Theme.of(context).accentColor)),
        ),
        FlatButton(
          onPressed: () {
            widget.onJoin(newJoiningMember);
          },
          child: Text('確定',
              style: TextStyle(color: Theme.of(context).accentColor)),
        ),
      ],
    );
  }
}

class GroupDetails extends StatefulWidget {
  final docId;
  bool isHistory = false;
  static bool inGroup = false;
  static bool hasGroup = false;
  static String myName = '';
  GroupDetails(this.docId, {this.isHistory = false});

  @override
  _GroupDetailsState createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails>
    with AutomaticKeepAliveClientMixin<GroupDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RequestService _request = RequestService();
  final DatabaseService _databaseService = DatabaseService();
  final NotifServices _notifServices = NotifServices();

  String transportation = '';
  String departure = '';
  String destination = '';
  String departure_location = '';
  String destination_location = '';
  DateTime departure_time;
  int maxMembers = 0;
  String reference_number;
  String covid;
  int joinedMember = 0;
  int waiting_time = 0;
  String sex = '';
  String tunnel = '';
  bool wait_all_member = false;

  int curUsers = 0;

  String ownerUser = '';

  bool require_permission;
  bool requestedToJoin;
  bool full = false;
  bool genderOK = true;

  Timer _countdownTimer;
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }

  void onShowLocationInMap(String location) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MapView(location)));
  }

  List<String> getAvailableNewMembers() {
    var ret = <String>[];
    for (var i = 1; i <= (maxMembers - joinedMember); i++) {
      ret.add(i.toString());
    }
    return ret;
  }

  void setArrived() async {
    var pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: '處理中..',
      backgroundColor: Theme.of(context).backgroundColor,
      messageTextStyle: TextStyle(color: Theme.of(context).accentColor),
    );
    await pr.show();
    await Future.delayed(Duration(seconds: 1));
    try {
      await _databaseService.setArrived(widget.docId);
      await pr.hide();
    } catch (e) {
      await pr.hide();
      print(e.toString());
    }
  }

  void onRequestJoin() async {
    try {
      await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text('Request To Join Group'),
              content:
                  Text('Are you sure you want to request to join this group?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Request',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () async {
                    ProgressDialog pr;
                    pr = ProgressDialog(context,
                        type: ProgressDialogType.Normal,
                        isDismissible: false,
                        showLogs: false);
                    pr.style(
                      message: 'Requesting...',
                      backgroundColor: Theme.of(context).backgroundColor,
                      messageTextStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                    );
                    await pr.show();
                    await Future.delayed(Duration(seconds: 1));
                    try {
                      await _notifServices.createRequest(widget.docId);
                      await Navigator.of(context).pop();
                      await pr.hide();
                    } catch (e) {
                      await pr.hide();
                      print(e.toString());
                    }
                  },
                ),
                FlatButton(
                  child: Text('Cancel',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

  void onJoinGroup() async {
    try {
      if (Global().isLoggedIn != true) {
        GUEST_SERVICE.showGuestModal(context);
        return;
      }

      await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AddNewJoinNum(getAvailableNewMembers(), onJoin);
          });
    } catch (e) {
      print(e.toString());
    }
  }

  void onJoin(int numUsers) async {
    ProgressDialog pr;
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: '加入群組中..',
      backgroundColor: Theme.of(context).backgroundColor,
      messageTextStyle: TextStyle(color: Theme.of(context).accentColor),
    );
    await pr.show();
    await Future.delayed(Duration(seconds: 1));
    try {
      await _request.joinGroup(widget.docId, numUsers);
      GroupDetails.inGroup = true;
      // await _notifServices
      //     .groupJoin(
      //         usersnapshot
      //             .data['name'],
      //         widget.docId);
      await pr.hide();
    } catch (e) {
      await pr.hide();
      print(e.toString());
    }
    Navigator.of(context).pop();
  }

  Widget buildTransInfo(
    bool wait_member,
    String useTunnel,
    String passenger_type,
  ) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: DottedLine(
                direction: Axis.horizontal,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 2.0,
                dashColor: grey_color3,
                dashRadius: 0.0,
                dashGapLength: 2.0,
                dashGapColor: Colors.transparent,
                dashGapRadius: 0.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(wait_member ? '   有權等待\n(上限10分鐘)' : '準時出發',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black)),
                ),
                Container(
                  width: 40,
                  child: SvgPicture.asset(
                    'assets/svgs/vert_divider.svg',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(useTunnel,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black)),
                ),
                Container(
                  width: 40,
                  child: SvgPicture.asset(
                    'assets/svgs/vert_divider.svg',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(passenger_type,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.red)),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: DottedLine(
                direction: Axis.horizontal,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 2.0,
                dashColor: grey_color3,
                dashRadius: 0.0,
                dashGapLength: 2.0,
                dashGapColor: Colors.transparent,
                dashGapRadius: 0.0,
              ),
            ),
          ],
        ));
  }

  Widget buildUserListItem(FirebaseUser curUser, Map<String, dynamic> userItem,
      dynamic usersInGroup) {
    var numUsers = 1;
    for (var i = 0; i < usersInGroup.length; i++) {
      if (usersInGroup[i]['uid'] == userItem['uid']) {
        numUsers = usersInGroup[i]['num'];
      }
    }

    if (widget.isHistory) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                userItem['name'] + (numUsers > 1 ? ' x $numUsers' : ''),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                userItem['mobilenum'],
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child:
          userItem['isArrived'] == true
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'IN',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'OUT',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red),
                  ))
          )
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              userItem['name'] + (numUsers > 1 ? ' x $numUsers' : ''),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
        ),
        userItem['isArrived'] == true
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '已到達',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ))
            : userItem['uid'] == curUser?.uid
                ? Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: FlatButton(
                        color: yellow_color1,
                        onPressed: () {
                          setArrived();
                        },
                        child: Text(
                          '到達',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        )))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '還未到達',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red),
                    ))
      ],
    );
  }

  Widget buildBottomBtn() {
    if (widget.isHistory) {
      return null;
    }

    if (GroupDetails.inGroup) {
      return FlatButton(
        color: yellow_color1,
        onPressed: () async {
          // await Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => GroupPage()));
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(widget.docId)));
        },
        height: 85,
        child: Text(
          '按此與團友溝通', // You are in a group and viewing a private group
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900, color: text_color2),
        ),
      );
    } else if (full == true) {
      return null;
      // return FlatButton(
      //   color: yellow_color1,
      //   padding: EdgeInsets.all(20),
      //   child: Text('Group is full',
      //       style: TextStyle(
      //           fontSize: 18, fontWeight: FontWeight.w900, color: text_color2)),
      // );
    } else if (require_permission == true) {
      if (requestedToJoin) {
        return null;
        // return FlatButton(
        //   padding: EdgeInsets.all(20),
        //   color: yellow_color1,
        //   child: Text('Requested',
        //       style: TextStyle(
        //           fontSize: 18,
        //           fontWeight: FontWeight.w900,
        //           color: text_color2)),
        // );
      } else {
        return null;
        // return FlatButton(
        //   padding: EdgeInsets.all(20),
        //   color: yellow_color1,
        //   onPressed: () {
        //     onRequestJoin();
        //   },
        //   child: Text('Request to Join',
        //       style: TextStyle(
        //           fontSize: 18,
        //           fontWeight: FontWeight.w900,
        //           color: text_color2)),
        // );
      }
    } else if (GroupDetails.hasGroup == false && genderOK == true) {
      // if require_permission == false
      return Container(
        height: 115,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              height: 30,
              color: text_color1,
              child: Center(
                child: Text(
                  '下一位可節省 50% 車資',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            FlatButton(
              height: 85,
              color: yellow_color1,
              onPressed: () {
                onJoinGroup();
              },
              child: Text('按此加入此團',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color:
                          text_color2)), // Visiting a public group page and not in any group
            )
          ],
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    timeDilation = 1.0;
    final currentuser = Provider.of<FirebaseUser>(context);
    return StreamBuilder(
        stream: Firestore.instance
            .collection('userdetails')
            .document(currentuser == null ? '' : currentuser.uid)
            .snapshots(),
        builder: (context, usersnapshot) {
          requestedToJoin = usersnapshot.hasData
              ? usersnapshot.data['currentGroupJoinRequests'] != null &&
                  usersnapshot.data['currentGroupJoinRequests']
                      .contains(widget.docId)
              : false;
          if (currentuser == null ||
              usersnapshot.connectionState == ConnectionState.active) {
            var groupUID;
            var myName = '';
            if (usersnapshot.data != null) {
              groupUID = usersnapshot.data['currentGroup'];
              myName = usersnapshot.data['name'];
            }
            if (groupUID != null) {
              GroupDetails.hasGroup = true;
            } else {
              GroupDetails.hasGroup = false;
            }
            if (groupUID == widget.docId) {
              GroupDetails.inGroup = true;
            } else {
              GroupDetails.inGroup = false;
            }
            GroupDetails.myName = myName;

            return StreamBuilder(
                stream: Firestore.instance
                    .collection('group')
                    .document(widget.docId)
                    .snapshots(),
                builder: (context, groupsnapshot) {
                  if (groupsnapshot.connectionState == ConnectionState.active) {
                    if (groupsnapshot.data == null ||
                        groupsnapshot.data.data == null) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      transportation = groupsnapshot.data['transportation'];
                      departure = groupsnapshot.data['departure'];
                      destination = groupsnapshot.data['destination'];
                      departure_location =
                          groupsnapshot.data['departure_location'];
                      destination_location =
                          groupsnapshot.data['destination_location'];
                      departure_time =
                          groupsnapshot.data['departure_time'].toDate();
                      maxMembers = groupsnapshot.data['maxMembers'];
                      reference_number = groupsnapshot.data['reference_number'];
                      covid = groupsnapshot.data['covid'];
                      curUsers = groupsnapshot.data['users'].length;
                      joinedMember = 0;
                      for (var i = 0;
                          i < groupsnapshot.data['users'].length;
                          i++) {
                        joinedMember = joinedMember +
                            groupsnapshot.data['users'][i]['num'];
                      }

                      waiting_time = groupsnapshot.data['waiting_time'];
                      sex = groupsnapshot.data['sex'];
                      tunnel = groupsnapshot.data['tunnel'];
                      wait_all_member = groupsnapshot.data['wait_all_member'];

                      if (joinedMember >= maxMembers) {
                        full = true;
                      } else {
                        full = false;
                      }

                      if (groupsnapshot.data['sex'] == '男女也可') {
                        genderOK = true;
                      } else if (groupsnapshot.data['sex'] == '只限男性' &&
                          usersnapshot.data['sex'] == '男性') {
                        genderOK = true;
                      } else if (groupsnapshot.data['sex'] == '只限女性' &&
                          usersnapshot.data['sex'] == '女性') {
                        genderOK = true;
                      } else {
                        genderOK = false;
                      }
                      ownerUser = groupsnapshot.data['owner'];
                    }

                    return Scaffold(
                        key: _scaffoldKey,
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
                          titleSpacing: 0,
                          title: Row(children: [
                            Image.asset(
                              'assets/images/logo_full_qq.png',
                              width: 160,
                              height: 22,
                            ),
                          ]),
                        ),
                        body: Column(
                          children: [
                            Container(
                                width: double.infinity,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: yellow_color1,
                                ),
                                child: Center(
                                  child: Text(
                                    '「一個同您搭都半價」慳錢、慳時間',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: text_color4,
                                    ),
                                  ),
                                )),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      color: Color(0xFFFFFFFF),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          TripItem(
                                            transportation: transportation,
                                            departure: departure,
                                            destination: destination,
                                            departure_loc: departure_location,
                                            destination_loc:
                                                destination_location,
                                            departure_time: departure_time,
                                            maxMember: maxMembers,
                                            joinedMember: joinedMember,
                                            reference_number: reference_number,
                                            covid: covid,
                                          ),
                                          buildTransInfo(
                                              wait_all_member, tunnel, sex),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: curUsers.toDouble() * 60,
                                      child: StreamBuilder(
                                        stream: Firestore.instance
                                            .collection('group')
                                            .document(widget.docId)
                                            .collection('users')
                                            .snapshots(),
                                        builder: (ctx, futureSnapshot) {
                                          if (futureSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Column(
                                              children: <Widget>[
                                                CircularProgressIndicator(),
                                              ],
                                            );
                                          }
                                          return ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: futureSnapshot
                                                  .data.documents.length,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (ctx, index) {
                                                return Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 20),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          bottom: BorderSide(
                                                              // width:
                                                              //     double.infinity,
                                                              color:
                                                                  grey_color6))),
                                                  width: double.infinity,
                                                  child: buildUserListItem(
                                                      currentuser,
                                                      futureSnapshot
                                                          .data
                                                          .documents[index]
                                                          .data,
                                                      groupsnapshot
                                                          .data['users']),
                                                );
                                              });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 100,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        bottomNavigationBar: buildBottomBtn());
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}
