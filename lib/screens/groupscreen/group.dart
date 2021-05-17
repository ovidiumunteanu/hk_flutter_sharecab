import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/screens/chatscreen/chat_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/screens/groupscreen/editgroup.dart';
import 'package:shareacab/screens/notifications/services/notifservices.dart';
import 'package:shareacab/services/trips.dart';
import 'package:shareacab/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage>
    with AutomaticKeepAliveClientMixin<GroupPage> {
  final RequestService _request = RequestService();
  final NotifServices _notifServices = NotifServices();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String groupUID = '';
  String destination = '';
  String dest_location = '';
  String departure_location = '';
  String departure_date = '';
  String departure_time = '';
  String grpOwner = '';
  int presentNum = 0;
  int maxPoolers = 0;
  bool loading = true;

  int i = 0, numberOfMessages = 696;
  double userRating;

  Future getMembers(String docid) async {
    var qp = await Firestore.instance
        .collection('group')
        .document(docid)
        .collection('users')
        .getDocuments();
    return qp.documents;
  }

  void _complete(String docid) async {
    await Firestore.instance
        .collection('group')
        .document(docid)
        .updateData({'end': true});
    Navigator.of(context).pop();
  }

  bool buttonEnabled = true;
  Timestamp endTimeStamp = Timestamp.now();
  bool timestampFlag = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Widget buildRowInfo(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 12),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 12),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  // fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentuser = Provider.of<FirebaseUser>(context);
    return StreamBuilder(
        stream: Firestore.instance
            .collection('userdetails')
            .document(currentuser.uid)
            .snapshots(),
        builder: (context, usersnapshot) {
          if (usersnapshot.connectionState == ConnectionState.active) {
            if (buttonEnabled == true) {
              groupUID = usersnapshot.data['currentGroup'];
            }
            if (usersnapshot.data['currentGroup'] == null) {
              Navigator.pop(context);
            }
            return StreamBuilder(
                stream: Firestore.instance
                    .collection('group')
                    .document(groupUID)
                    .snapshots(),
                builder: (context, groupsnapshot) {
                  if (groupsnapshot.connectionState == ConnectionState.active) {
                    if (buttonEnabled == true) {
                      destination = groupsnapshot.data['destination'];
                      dest_location =
                          groupsnapshot.data['destination_location'];
                      departure_location =
                          groupsnapshot.data['departure_location'];
                      departure_date =
                          "${DateFormat('yyyy.MM.dd').format(groupsnapshot.data['departure_time'].toDate())}";
                      departure_time =
                          "${DateFormat('kk:mm a').format(groupsnapshot.data['departure_time'].toDate())}";

                      grpOwner = groupsnapshot.data['owner'];
                      presentNum = groupsnapshot.data['users'].length;
                      maxPoolers = groupsnapshot.data['maxPoolers'];
                      loading = false;
                    }

                    return loading
                        ? Loading()
                        : Scaffold(
                            appBar: AppBar(
                              title: Text('Group Details'),
                              actions: <Widget>[
                                buttonEnabled
                                    ? timestampFlag
                                        ? FlatButton.icon(
                                            textColor:
                                                getVisibleColorOnPrimaryColor(
                                                    context),
                                            icon: Icon(
                                                FontAwesomeIcons.signOutAlt),
                                            onPressed: () async {
                                              try {
                                                await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext ctx) {
                                                      return AlertDialog(
                                                        title: Text('End Trip'),
                                                        content: Text(
                                                            'Are you sure you want to end this trip?'),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0)),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child: Text('End',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor)),
                                                            onPressed:
                                                                () async {
                                                              ProgressDialog pr;
                                                              pr = ProgressDialog(
                                                                  context,
                                                                  type: ProgressDialogType
                                                                      .Normal,
                                                                  isDismissible:
                                                                      false,
                                                                  showLogs:
                                                                      false);
                                                              pr.style(
                                                                message:
                                                                    'Ending Trip...',
                                                                backgroundColor:
                                                                    Theme.of(
                                                                            context)
                                                                        .backgroundColor,
                                                                messageTextStyle:
                                                                    TextStyle(
                                                                  color: getVisibleTextColorOnScaffold(
                                                                      context),
                                                                ),
                                                              );
                                                              await pr.show();
                                                              await Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          1));
                                                              try {
                                                                buttonEnabled =
                                                                    false;
                                                                await _request
                                                                    .exitGroup();
                                                                Navigator.pop(
                                                                    context);
                                                                await pr.hide();
                                                              } catch (e) {
                                                                await pr.hide();
                                                                print(e
                                                                    .toString());
                                                                var errStr =
                                                                    e.message ==
                                                                            null
                                                                        ? ""
                                                                        : e.toString();
                                                                final snackBar = SnackBar(
                                                                    content: Text(
                                                                        errStr),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            3));
                                                                scaffoldKey
                                                                    .currentState
                                                                    .showSnackBar(
                                                                        snackBar);
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          FlatButton(
                                                            child: Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor)),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              } catch (e) {
                                                print(e.toString());
                                              }
                                            },
                                            label: Text('End Trip'),
                                          )
                                        : FlatButton.icon(
                                            textColor:
                                                getVisibleColorOnPrimaryColor(
                                                    context),
                                            icon: Icon(
                                                FontAwesomeIcons.signOutAlt),
                                            onPressed: () async {
                                              try {
                                                await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext ctx) {
                                                      return AlertDialog(
                                                        title:
                                                            Text('Leave Group'),
                                                        content: Text(
                                                            'Are you sure you want to leave this group?'),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0)),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child: Text('Leave',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor)),
                                                            onPressed:
                                                                () async {
                                                              ProgressDialog pr;
                                                              pr = ProgressDialog(
                                                                  context,
                                                                  type: ProgressDialogType
                                                                      .Normal,
                                                                  isDismissible:
                                                                      false,
                                                                  showLogs:
                                                                      false);
                                                              pr.style(
                                                                message:
                                                                    'Leaving Group...',
                                                                backgroundColor:
                                                                    Theme.of(
                                                                            context)
                                                                        .backgroundColor,
                                                                messageTextStyle:
                                                                    TextStyle(
                                                                  color: getVisibleTextColorOnScaffold(
                                                                      context),
                                                                ),
                                                              );
                                                              await pr.show();
                                                              await Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          1));
                                                              try {
                                                                buttonEnabled =
                                                                    false;
                                                                await _notifServices.leftGroup(
                                                                    usersnapshot
                                                                            .data[
                                                                        'name'],
                                                                    groupUID);
                                                                await _request
                                                                    .exitGroup();
                                                                Navigator.pop(
                                                                    context);
                                                                await pr.hide();
                                                              } catch (e) {
                                                                await pr.hide();
                                                                print(e
                                                                    .toString());
                                                                String errStr =
                                                                    e.message ==
                                                                            null
                                                                        ? ""
                                                                        : e.toString();
                                                                final snackBar = SnackBar(
                                                                    content: Text(
                                                                        errStr),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            3));
                                                                scaffoldKey
                                                                    .currentState
                                                                    .showSnackBar(
                                                                        snackBar);
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          FlatButton(
                                                            child: Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor)),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              } catch (e) {
                                                print(e.toString());
                                              }
                                            },
                                            label: Text('Leave Group'),
                                          )
                                    : timestampFlag
                                        ? FlatButton.icon(
                                            textColor:
                                                getVisibleColorOnPrimaryColor(
                                                    context),
                                            icon: Icon(
                                                FontAwesomeIcons.signOutAlt),
                                            onPressed: null,
                                            label: Text('End Trip'),
                                          )
                                        : FlatButton.icon(
                                            textColor:
                                                getVisibleColorOnPrimaryColor(
                                                    context),
                                            icon: Icon(
                                                FontAwesomeIcons.signOutAlt),
                                            onPressed: null,
                                            label: Text('Leave Group'),
                                          )
                              ],
                            ),
                            body: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 30, bottom: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: Text(
                                                    destination,
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Text(
                                                  dest_location,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                          grpOwner == currentuser.uid
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 10,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: <Widget>[
                                                      Text(
                                                          'Press here to edit the details: '),
                                                      FlatButton.icon(
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        EditGroup(
                                                                            groupUID:
                                                                                groupUID)));
                                                          },
                                                          icon: Icon(
                                                            FontAwesomeIcons
                                                                .pen,
                                                            size: 16.0,
                                                            color:
                                                                getVisibleTextColorOnScaffold(
                                                                    context),
                                                          ),
                                                          label: Text(
                                                            'Edit',
                                                            style: TextStyle(
                                                              color:
                                                                  getVisibleTextColorOnScaffold(
                                                                      context),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 10,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '*Contact group admin to edit details.',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          buildRowInfo('Departure Location : ',
                                              departure_location),
                                          buildRowInfo('Departure Date : ',
                                              departure_date),
                                          buildRowInfo('Departure Time : ',
                                              departure_time),
                                          buildRowInfo(
                                              'Rule : ',
                                              groupsnapshot.data['rule'] +
                                                  ', ' +
                                                  groupsnapshot.data['sex']),
                                          buildRowInfo('No. of members : ',
                                              maxPoolers.toString()),
                                          buildRowInfo(
                                              'Waiting time limited: ',
                                              groupsnapshot.data['waiting_time']
                                                      .toString() +
                                                  ' minutes'),
                                          buildRowInfo(
                                              'Required wait for all members arrive before going? : ',
                                              groupsnapshot.data[
                                                          'wait_all_member'] ==
                                                      true
                                                  ? 'Yes'
                                                  : 'No'),
                                          buildRowInfo(
                                              'Required permission to join trip? : ',
                                              groupsnapshot.data[
                                                          'require_permission'] ==
                                                      true
                                                  ? 'Yes'
                                                  : 'No'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                grpOwner == currentuser.uid
                                    ? Container(
                                        height: 50,
                                        width: double.infinity,
                                        margin: EdgeInsets.only(
                                          top: 40,
                                        ),
                                        child: RaisedButton(
                                          textColor:
                                              getVisibleColorOnAccentColor(
                                                  context),
                                          onPressed: () {
                                            _complete(groupUID);
                                          },
                                          color: Theme.of(context).accentColor,
                                          child: Text('Completed',
                                              style: TextStyle(fontSize: 18)),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            floatingActionButton: Padding(
                              padding: const EdgeInsets.only(bottom: 50.0),
                              child: FloatingActionButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChatScreen(groupUID)));
                                },
                                child: Stack(
                                  alignment: Alignment(-10, -10),
                                  children: <Widget>[
                                    Tooltip(
                                      message: 'Messages',
                                      verticalOffset: 30,
                                      child: Icon(Icons.chat),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                  } else {
                    return Container(
                        child: Center(child: CircularProgressIndicator()));
                  }
                });
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class Members {
  String name;
  bool isAdmin;
  String hostel;

  Members({@required this.name, @required this.isAdmin, @required this.hostel});
}

Widget showRating(double rating) {
  var row = Row(
    children: <Widget>[],
  );
  var fullStars = rating.floor();
  var halfStar = rating - fullStars >= 0.5 ? 1 : 0;
  var emptyStars = (5 - fullStars - halfStar);
  for (var i = 0; i < fullStars; i++) {
    row.children.add(Icon(Icons.star));
  }
  for (var i = 0; i < halfStar; i++) {
    row.children.add(Icon(Icons.star_half));
  }
  for (var i = 0; i < emptyStars; i++) {
    row.children.add(Icon(Icons.star_border));
  }
  return row;
}
