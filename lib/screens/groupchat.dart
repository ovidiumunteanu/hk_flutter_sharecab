import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/components/TopMessage.dart';
import 'package:shareacab/services/auth.dart';
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
import 'package:shareacab/components/appbar.dart';

class GroupChatScreen extends StatefulWidget {
  static bool hasGroup = false;
  static String myName = '';
  static String docId = '';
  GroupChatScreen();

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen>
    with AutomaticKeepAliveClientMixin<GroupChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RequestService _request = RequestService();
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _auth = AuthService();
  final NotifServices _notifServices = NotifServices();

  String transportation = '';
  String departure = '';
  String destination = '';
  String departure_sub = '';
  String destination_sub = '';
  String departure_location = '';
  String destination_location = '';
  DateTime departure_time;
  int maxMembers = 0;
  int joinedMember = 0;
  String reference_number;
  String covid;
  int waiting_time = 0;
  String sex = '';
  String tunnel = '';
  bool wait_all_member = false;

  var isFav = false;

  String ownerUser = '';

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
      await _databaseService.setArrived(GroupChatScreen.docId);
      await pr.hide();
    } catch (e) {
      await pr.hide();
      print(e.toString());
    }
  }

  void onLeaveGroup() async {
    try {
      await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text('離開群組'),
              content: Text('您確定要離開這群組嗎？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('取消',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('確認',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () async {
                    ProgressDialog pr;
                    pr = ProgressDialog(context,
                        type: ProgressDialogType.Normal,
                        isDismissible: false,
                        showLogs: false);
                    pr.style(
                      message: '離開群組中..',
                      backgroundColor: Theme.of(context).backgroundColor,
                      messageTextStyle: TextStyle(
                        color: text_color1,
                      ),
                    );
                    await pr.show();
                    await Future.delayed(Duration(seconds: 1));
                    try {
                      await _notifServices.leftGroup(
                          GroupChatScreen.myName, GroupChatScreen.docId);
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
              ],
            );
          });
    } catch (e) {
      print(e.toString());
    }
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              userItem['name'] + (numUsers > 1 ? ' x $numUsers 乘客' : ''),
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
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: (Platform.isIOS ? 80 : 55)),
        height: 70,
        child: FlatButton(
          color: yellow_color1,
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(GroupChatScreen.docId)));
          },
          padding: EdgeInsets.all(20),
          child: Text(
            '按此與團友溝通', // You are in a group and viewing a private group
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: text_color2),
          ),
        ));
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
          if (usersnapshot.connectionState == ConnectionState.active) {
            var groupUID = usersnapshot.data['currentGroup'];
            if (groupUID != null) {
              GroupChatScreen.hasGroup = true;
            } else {
              GroupChatScreen.hasGroup = false;
            }
            GroupChatScreen.docId = groupUID;
            GroupChatScreen.myName = usersnapshot.data['name'];

            return groupUID == null
                ? Scaffold(
                    key: _scaffoldKey,
                    backgroundColor: Colors.white,
                    appBar: CustomAppBar(context, _auth, currentuser),
                    body: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        TopMessage(),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 100),
                              child: Text('您目前沒有群組。'),
                            ),
                          ],
                        ))
                      ],
                    ),
                  )
                : StreamBuilder(
                    stream: Firestore.instance
                        .collection('group')
                        .document(groupUID)
                        .snapshots(),
                    builder: (context, groupsnapshot) {
                      if (groupsnapshot.connectionState ==
                          ConnectionState.active) {
                        if (groupsnapshot.data == null ||
                            groupsnapshot.data.data == null) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          transportation = groupsnapshot.data['transportation'];
                          departure = groupsnapshot.data['departure'];
                          destination = groupsnapshot.data['destination'];

                          departure_sub = groupsnapshot.data['departure_sub'];
                          destination_sub =
                              groupsnapshot.data['destination_sub'];

                          departure_location =
                              groupsnapshot.data['departure_location'];
                          destination_location =
                              groupsnapshot.data['destination_location'];
                          departure_time =
                              groupsnapshot.data['departure_time'].toDate();
                          maxMembers = groupsnapshot.data['maxMembers'];
                          reference_number =
                              groupsnapshot.data['reference_number'];
                          covid = groupsnapshot.data['covid'];

                          joinedMember = 0;
                          for (var i = 0;
                              i < groupsnapshot.data['users'].length;
                              i++) {
                            joinedMember = joinedMember +
                                groupsnapshot.data['users'][i]['num'];
                          }

                          isFav = false;
                          if (groupsnapshot.data['favs'] != null) {
                            if (groupsnapshot.data['favs']
                                .contains(currentuser.uid)) {
                              isFav = true;
                            }
                          }

                          waiting_time = groupsnapshot.data['waiting_time'];
                          sex = groupsnapshot.data['sex'];
                          tunnel = groupsnapshot.data['tunnel'];
                          wait_all_member =
                              groupsnapshot.data['wait_all_member'];

                          if (joinedMember >= maxMembers) {
                            full = true;
                          } else {
                            full = false;
                          }
                          ownerUser = groupsnapshot.data['owner'];
                        }
                        return Scaffold(
                            key: _scaffoldKey,
                            backgroundColor: Colors.white,
                            appBar: CustomAppBar(context, _auth, currentuser),
                            body: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  TopMessage(),
                                  Container(
                                    width: double.infinity,
                                    color: Color(0xFFFAFAFA),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TripItem(
                                          transportation: transportation,
                                          departureSub: departure_sub,
                                          destinationSub: destination_sub,
                                          departure_loc: departure_location,
                                          destination_loc: destination_location,
                                          departure_time: departure_time,
                                          maxMember: maxMembers,
                                          joinedMember: joinedMember,
                                          reference_number: reference_number,
                                          covid: covid,
                                          isFav: isFav,
                                          group_id: groupUID,
                                        ),
                                        buildTransInfo(
                                            wait_all_member, tunnel, sex),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: groupsnapshot.data['users'].length
                                            .toDouble() *
                                        60,
                                    child: StreamBuilder(
                                      stream: Firestore.instance
                                          .collection('group')
                                          .document(groupUID)
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
                                                        .documents[index].data,
                                                    groupsnapshot
                                                        .data['users']),
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                  Container(
                                      width: 200,
                                      height: 40,
                                      margin: EdgeInsets.only(top: 25),
                                      child: InkWell(
                                        onTap: () {
                                          onLeaveGroup();
                                        },
                                        child: Center(
                                          child: Text(
                                            '按此離開群組',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            bottomNavigationBar:
                                groupUID == null ? null : buildBottomBtn());
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
