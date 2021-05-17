import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/screens/groupdetailscreen/mapview.dart';
import 'package:shareacab/screens/groupscreen/group.dart';
import 'package:shareacab/services/database.dart';
import 'dart:io';

import 'package:shareacab/services/trips.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shareacab/main.dart';
import 'package:flutter/scheduler.dart';

import 'package:shareacab/screens/notifications/services/notifservices.dart';
import './appbar.dart';

class GroupDetails extends StatefulWidget {
  final String destination;
  final docId;
  final require_permission;
  final start;
  final numberOfMembers;
  final data;

  GroupDetails(this.destination, this.docId, this.require_permission,
      this.start, this.numberOfMembers, this.data);
  static bool inGroup = false;

  @override
  _GroupDetailsState createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails>
    with AutomaticKeepAliveClientMixin<GroupDetails> {
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

  bool require_permission;
  String destination = '';
  String dest_location = '';
  String departure_location = '';
  String departure_date = '';
  String departure_time = '';
  bool requestedToJoin;

  int present = 0;
  int max = 0;
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
      message: 'Setting arrived status..',
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

  Widget buildUserListItem(
      FirebaseUser curUser, Map<String, dynamic> userItem) {
    return Card(
      elevation: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(userItem['name']),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(userItem['hostel']),
          ),
          userItem['isArrived'] == true
              ? Padding(
                  padding: const EdgeInsets.all(16.0), child: Text('Arrived'))
              : userItem['uid'] == curUser.uid
                  ? Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: FlatButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            setArrived();
                          },
                          child: Text('Arrived')))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Not arrived'))
        ],
      ),
    );
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
              GroupDetails.inGroup = true;
            } else {
              GroupDetails.inGroup = false;
            }
            return StreamBuilder(
                stream: Firestore.instance
                    .collection('group')
                    .document(widget.docId)
                    .snapshots(),
                builder: (context, groupsnapshot) {
                  if (groupsnapshot.connectionState == ConnectionState.active) {
                    destination = groupsnapshot.data['destination'];
                    dest_location = groupsnapshot.data['destination_location'];
                    departure_location =
                        groupsnapshot.data['departure_location'];
                    departure_date =
                        "${DateFormat('yyyy.MM.dd').format(groupsnapshot.data['departure_time'].toDate())}";
                    departure_time =
                        "${DateFormat('kk:mm a').format(groupsnapshot.data['departure_time'].toDate())}";
                    present = groupsnapshot.data['users'].length;
                    max = groupsnapshot.data['maxPoolers'];
                    require_permission =
                        groupsnapshot.data['require_permission'];
                    if (present >= max) {
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
                              flexibleSpace: FlexibleSpaceBar(
                                title: AppBarTitle(''),
                              ),
                            ),
                          ];
                        },
                        body: Scaffold(
                          body: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Departure Location'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(departure_location),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: IconButton(
                                            onPressed: () async {
                                              try {
                                                onShowLocationInMap(
                                                    departure_location);
                                              } catch (e) {}
                                            },
                                            icon: Icon(
                                              Icons.pin_drop,
                                              color:
                                                  Theme.of(context).accentColor,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height - 240,
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
                                                  vertical: 0, horizontal: 10),
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
                              ],
                            ),
                          ),
                          bottomNavigationBar: FlatButton(
                            textColor: getVisibleColorOnAccentColor(context),
                            onPressed: () async {
                              try {
                                if (GroupDetails.inGroup) {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GroupPage()));
                                } else if (full) {
                                  null;
                                } else if (require_permission == true &&
                                    !full) {
                                  requestedToJoin
                                      ? null
                                      // print('already req')
                                      : await showDialog(
                                          context: context,
                                          builder: (BuildContext ctx) {
                                            return AlertDialog(
                                              title:
                                                  Text('Request To Join Group'),
                                              content: Text(
                                                  'Are you sure you want to request to join this group?'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Request',
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .accentColor)),
                                                  onPressed: () async {
                                                    ProgressDialog pr;
                                                    pr = ProgressDialog(context,
                                                        type: ProgressDialogType
                                                            .Normal,
                                                        isDismissible: false,
                                                        showLogs: false);
                                                    pr.style(
                                                      message: 'Requesting...',
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .backgroundColor,
                                                      messageTextStyle:
                                                          TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor),
                                                    );
                                                    await pr.show();
                                                    await Future.delayed(
                                                        Duration(seconds: 1));
                                                    try {
                                                      await _notifServices
                                                          .createRequest(
                                                              widget.docId);
                                                      await Navigator.of(
                                                              context)
                                                          .pop();
                                                      await pr.hide();
                                                    } catch (e) {
                                                      await pr.hide();
                                                      print(e.toString());
                                                    }
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text('Cancel',
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .accentColor)),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                } else if (require_permission == false &&
                                    !full) {
                                  await showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: Text('Join Group'),
                                          content: Text(
                                              'Are you sure you want to join this group?'),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('Join',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .accentColor)),
                                              onPressed: () async {
                                                ProgressDialog pr;
                                                pr = ProgressDialog(context,
                                                    type: ProgressDialogType
                                                        .Normal,
                                                    isDismissible: false,
                                                    showLogs: false);
                                                pr.style(
                                                  message: 'Joining Group...',
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .backgroundColor,
                                                  messageTextStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                );
                                                await pr.show();
                                                await Future.delayed(
                                                    Duration(seconds: 1));
                                                try {
                                                  await _request
                                                      .joinGroup(widget.docId);
                                                  GroupDetails.inGroup = true;
                                                  await _notifServices
                                                      .groupJoin(
                                                          usersnapshot
                                                              .data['name'],
                                                          widget.docId);
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
                                              child: Text('Cancel',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .accentColor)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                }
                              } catch (e) {
                                print(e.toString());
                              }
                            },
                            padding: EdgeInsets.all(20),
                            child: require_permission == true
                                ? GroupDetails.inGroup
                                    ? Text(
                                        'My Group Page', // You are in a group and viewing a private group
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: getVisibleColorOnAccentColor(
                                                context)),
                                      )
                                    : full
                                        ? Text('Group is full',
                                            style: TextStyle(fontSize: 20))
                                        : requestedToJoin
                                            ? Text(
                                                'Requested', // You are not in any group and requested to join
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color:
                                                        getVisibleColorOnAccentColor(
                                                            context)),
                                              )
                                            : Text(
                                                'Request to Join', // fresh visit to private group (and user is not in any group)
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color:
                                                        getVisibleColorOnAccentColor(
                                                            context)),
                                              )
                                : GroupDetails.inGroup
                                    ? Text(
                                        'My Group Page', // visiting a group page
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: getVisibleColorOnAccentColor(
                                                context)),
                                      )
                                    : full
                                        ? Text('Group is full',
                                            style: TextStyle(fontSize: 20))
                                        : Text('Join Now',
                                            style: TextStyle(
                                                fontSize:
                                                    20)), // Visiting a public group page and not in any group
                            color: Theme.of(context).accentColor,
                          ),
                        ));
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
