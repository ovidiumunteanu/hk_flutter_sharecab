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
import 'package:shareacab/utils/constant.dart';
import 'package:shareacab/components/TripItem.dart';
import 'package:shareacab/screens/notifications/services/notifservices.dart';
import './appbar.dart';

class GroupDetails extends StatefulWidget {
  final docId;
  final data;
  static bool inGroup = false;
  static bool hasGroup = false;
  static String myName = '';
  GroupDetails(this.docId, this.data);

  @override
  _GroupDetailsState createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails>
    with AutomaticKeepAliveClientMixin<GroupDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RequestService _request = RequestService();
  final DatabaseService _databaseService = DatabaseService();
  final NotifServices _notifServices = NotifServices();
  Future getUserDetails() async {
    final userDetails = await Firestore.instance
        .collection('group')
        .document(widget.docId)
        .collection('users')
        .snapshots();
    return userDetails;
  }

  String transportation = '';
  String departure = '';
  String destination = '';
  String departure_location = '';
  String destination_location = '';
  DateTime departure_time;
  int maxMembers = 0;
  int joinedMember = 0;
  int waiting_time = 0;
  String sex = '';
  String tunnel = '';
  bool wait_all_member = false;

  bool require_permission;
  bool requestedToJoin;
  bool full = false;

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

  void setArrived() async {
    var pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: '设置到达状态..',
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
      await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text('加入组'),
              content: Text('您确定要加入此群组吗？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('加入',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () async {
                    ProgressDialog pr;
                    pr = ProgressDialog(context,
                        type: ProgressDialogType.Normal,
                        isDismissible: false,
                        showLogs: false);
                    pr.style(
                      message: '加入群...',
                      backgroundColor: Theme.of(context).backgroundColor,
                      messageTextStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                    );
                    await pr.show();
                    await Future.delayed(Duration(seconds: 1));
                    try {
                      await _request.joinGroup(widget.docId);
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
                    // final snackBar = SnackBar(
                    //   backgroundColor: Theme.of(context).primaryColor,
                    //   content: Text(
                    //     'Yayyy!! You joined the trip.',
                    //     style: TextStyle(color: Theme.of(context).accentColor),
                    //   ),
                    //   duration: Duration(seconds: 1),
                    // );
                    // Scaffold.of(ctx).hideCurrentSnackBar();
                    // Scaffold.of(ctx).showSnackBar(snackBar);
                  },
                ),
                FlatButton(
                  child: Text('取消',
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

  void onLeaveGroup() async {
    try {
      await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text('離開組'),
              content: Text('你確定要離開這個群嗎？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('是的',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () async {
                    ProgressDialog pr;
                    pr = ProgressDialog(context,
                        type: ProgressDialogType.Normal,
                        isDismissible: false,
                        showLogs: false);
                    pr.style(
                      message: '離開組...',
                      backgroundColor: Theme.of(context).backgroundColor,
                      messageTextStyle: TextStyle(
                        color: text_color1,
                      ),
                    );
                    await pr.show();
                    await Future.delayed(Duration(seconds: 1));
                    try {
                      await _notifServices.leftGroup(
                          GroupDetails.myName, widget.docId);
                      await _request.exitGroup();
                      Navigator.pop(context);
                      await pr.hide();
                    } catch (e) {
                      await pr.hide();
                      print(e.toString());
                      var errStr = e.message == null ? '' : e.toString();
                      final snackBar = SnackBar(
                          content: Text(errStr),
                          duration: Duration(seconds: 3));
                      _scaffoldKey.currentState.showSnackBar(snackBar);
                    }
                    // Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('取消',
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

  Widget buildTransInfo(
    String transport,
    String useTunnel,
    String passenger_type,
  ) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12),
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
                  child: Text(transport,
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
              padding: EdgeInsets.only(top: 12),
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

  Widget buildUserListItem(
      FirebaseUser curUser, Map<String, dynamic> userItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              userItem['name'],
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
            : userItem['uid'] == curUser.uid
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
        padding: EdgeInsets.all(20),
        child: Text(
          '进入聊天室', // You are in a group and viewing a private group
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
    } else if (GroupDetails.hasGroup == false) {
      // if require_permission == false
      return Container(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              height: 30,
              color: text_color1,
              child: Center(
                child: Text(
                  '下次加入将节省 50%',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            FlatButton(
              height: 70,
              color: yellow_color1,
              onPressed: () {
                onJoinGroup();
              },
              child: Text('加入此群組',
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
            .document(currentuser.uid)
            .snapshots(),
        builder: (context, usersnapshot) {
          requestedToJoin = usersnapshot.hasData
              ? usersnapshot.data['currentGroupJoinRequests'] != null &&
                  usersnapshot.data['currentGroupJoinRequests']
                      .contains(widget.docId)
              : false;
          if (usersnapshot.connectionState == ConnectionState.active) {
            var groupUID = usersnapshot.data['currentGroup'];
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
            GroupDetails.myName = usersnapshot.data['name'];

            return StreamBuilder(
                stream: Firestore.instance
                    .collection('group')
                    .document(widget.docId)
                    .snapshots(),
                builder: (context, groupsnapshot) {
                  if (groupsnapshot.connectionState == ConnectionState.active) {
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
                    joinedMember = groupsnapshot.data['users'].length;

                    waiting_time = groupsnapshot.data['waiting_time'];
                    sex = groupsnapshot.data['sex'];
                    tunnel = groupsnapshot.data['tunnel'];
                    wait_all_member = groupsnapshot.data['wait_all_member'];

                    if (joinedMember >= maxMembers) {
                      full = true;
                    } else {
                      full = false;
                    }
                    return NestedScrollView(
                        controller: ScrollController(keepScrollOffset: true),
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverAppBar(
                              pinned: true,
                              floating: false,
                              expandedHeight: 40,
                              titleTextStyle: TextStyle(fontSize: 14),
                              leading: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.chevron_left,
                                  color: text_color1,
                                  size: 36,
                                ),
                              ),
                              flexibleSpace: FlexibleSpaceBar(
                                titlePadding: EdgeInsets.only(
                                  left: 48,
                                  bottom: 7,
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/logo.png',
                                      width: 35,
                                      height: 40,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'AA制車資',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: text_color1),
                                    ),
                                  ],
                                ),
                              ),
                              backgroundColor: yellow_color2,
                              actions: <Widget>[
                                GroupDetails.inGroup
                                    ? FlatButton(
                                        onPressed: () {
                                          onLeaveGroup();
                                        },
                                        child: Text(
                                          '離開組',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: text_color1),
                                        ))
                                    : Container(),
                                // IconButton(
                                //   icon: Icon(
                                //     Icons.filter_list,
                                //     color: text_color1,
                                //     size: 30.0,
                                //   ),
                                //   tooltip: 'Filter',
                                //   onPressed: () async {
                                //     // _startFilter(context);
                                //   },
                                // ),
                                // IconButton(
                                //   icon: Icon(
                                //     Icons.help,
                                //     color: text_color1,
                                //   ),
                                //   tooltip: 'Help',
                                //   onPressed: () {
                                //     // Navigator.push(
                                //     //     context,
                                //     //     MaterialPageRoute(
                                //     //         builder: (context) => Help()));
                                //   },
                                // ),
                                // IconButton(
                                //     icon: Icon(
                                //       Icons.settings,
                                //       color: text_color1,
                                //     ),
                                //     tooltip: 'Settings',
                                //     onPressed: () {
                                //       // return Navigator.push(context,
                                //       //     MaterialPageRoute(builder: (context) {
                                //       //   return Settings(_auth);
                                //       // }));
                                //     }),
                              ],
                            ),
                          ];
                        },
                        body: Scaffold(
                            key: _scaffoldKey,
                            backgroundColor: Colors.white,
                            body: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                      width: double.infinity,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: yellow_color1,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '「一個都半價」慳錢、慳時間。',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: text_color4,
                                          ),
                                        ),
                                      )),
                                  Container(
                                    width: double.infinity,
                                    color: Color(0xFFFAFAFA),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TripItem(
                                          departure: departure,
                                          destination: destination,
                                          departure_loc: departure_location,
                                          destination_loc: destination_location,
                                          departure_time: departure_time,
                                          maxMember: maxMembers,
                                          joinedMember: joinedMember,
                                        ),
                                        buildTransInfo(
                                            transportation, tunnel, sex),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: joinedMember.toDouble() * 60,
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
                                                    futureSnapshot.data
                                                        .documents[index].data),
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 40),
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 50,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '* Going without waiting all passenger join',
                                          style: TextStyle(
                                              fontSize: 12, color: text_color2),
                                        ),
                                        SizedBox(
                                          height: 17,
                                        ),
                                        Text(
                                          wait_all_member
                                              ? '此群組有權「準時出發」及不再等待個別團友。*如果有團友遲到或沒有回覆狀況的情況下，此群組有權「準時出發」。'
                                              : '此群組有權「等待團友到達」才可以出發。*如果有團友遲到或未到達的情況下，此群組有權「等待團友到達」才可出發。',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            bottomNavigationBar: buildBottomBtn()));
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
