import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/utils/constant.dart';

import 'groupdetailscreen/groupdetails.dart';
import 'groupscreen/group.dart';

class TripsList extends StatefulWidget {
  final bool inGroupFetch;
  final bool inGroup;
  final _dest;
  final _notPrivate;
  final _selectedDestination;
  final Function startCreatingTrip;
  TripsList(this._dest, this._selectedDestination, this._notPrivate,
      {this.inGroupFetch, this.inGroup, this.startCreatingTrip});
  @override
  _TripsListState createState() => _TripsListState();
}

class _TripsListState extends State<TripsList>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  AnimationController _hideFabController;
  bool flag;
  var requestsArray = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _hideFabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: 1,
    );
  }

  Widget buildRowInfo(String key, String value) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: Text(
            key,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w400, color: text_color3),
            textAlign: TextAlign.start,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: text_color1),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentuser = Provider.of<FirebaseUser>(context);
    return Scaffold(
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('userdetails')
                .document(currentuser.uid)
                .snapshots(),
            builder: (_, usersnapshot) {
              if (usersnapshot.connectionState == ConnectionState.waiting) {
                Center(child: CircularProgressIndicator());
              }
              if (usersnapshot.connectionState == ConnectionState.active) {
                requestsArray = usersnapshot.data['currentGroupJoinRequests'];
                requestsArray ??= [];
              }

              _controller.addListener(() {
                switch (_controller.position.userScrollDirection) {
                  // Scrolling up - forward the animation (value goes to 1)
                  case ScrollDirection.forward:
                    _hideFabController.forward();
                    break;
                  // Scrolling down - reverse the animation (value goes to 0)
                  case ScrollDirection.reverse:
                    _hideFabController.reverse();
                    break;
                  // Idle - keep FAB visibility unchanged
                  case ScrollDirection.idle:
                    break;
                }
              });
              return Container(
                child: StreamBuilder(
                  stream: widget._dest == true && widget._notPrivate == true
                      ? Firestore.instance
                          .collection('group')
                          .where('destination',
                              isEqualTo: widget._selectedDestination)
                          .where('require_permission', isEqualTo: false)
                          .where('end', isEqualTo: false)
                          .orderBy('departure_time', descending: true)
                          .snapshots()
                      : widget._dest == true
                          ? Firestore.instance
                              .collection('group')
                              .where('destination',
                                  isEqualTo: widget._selectedDestination)
                              .where('end', isEqualTo: false)
                              .orderBy('departure_time', descending: true)
                              .snapshots()
                          : widget._notPrivate == true
                              ? Firestore.instance
                                  .collection('group')
                                  .where('require_permission', isEqualTo: false)
                                  .where('end', isEqualTo: false)
                                  .orderBy('departure_time', descending: true)
                                  .snapshots()
                              : Firestore.instance
                                  .collection('group')
                                  .where('end', isEqualTo: false)
                                  .orderBy('departure_time', descending: true)
                                  .snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                        controller: _controller,
                        physics: BouncingScrollPhysics(),
                        itemCount: snapshot.data == null
                            ? 0
                            : snapshot.data.documents.length,
                        itemBuilder: (ctx, index) {
                          final destination = snapshot
                              .data.documents[index].data['destination'];
                          final departure_time = snapshot
                              .data.documents[index].data['departure_time']
                              .toDate();
                          final docId =
                              snapshot.data.documents[index].documentID;
                          final require_permission = snapshot
                              .data.documents[index].data['require_permission'];
                          final numberOfMembers = snapshot
                              .data.documents[index].data['numberOfMembers'];
                          final data = snapshot.data.documents[index];
                          if (docId == usersnapshot.data['currentGroup']) {
                            flag = true;
                          } else {
                            flag = false;
                          }
                          return Hero(
                            tag: docId,
                            child: Card(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              elevation: 0.0,
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GroupDetails(
                                              destination,
                                              docId,
                                              require_permission,
                                              departure_time,
                                              numberOfMembers,
                                              data)));
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 0),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 12,
                                        bottom: 12,
                                        left: 25,
                                        right: 25),
                                    child: SingleChildScrollView(
                                        child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      // Text('${snapshot.data.documents[index].data['destination']}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: red_color2),),
                                                      Text(
                                                        '觀塘',
                                                        style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: red_color2),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5,
                                                                left: 12,
                                                                right: 12),
                                                        child: Text(
                                                          '往',
                                                          style: TextStyle(
                                                              color:
                                                                  text_color3),
                                                        ),
                                                      ),
                                                      Text(
                                                        '${snapshot.data.documents[index].data['destination_location']}',
                                                        style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: grey_color4),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5,
                                                                left: 12,
                                                                right: 12),
                                                        child: Text(
                                                          '於',
                                                          style: TextStyle(
                                                              color:
                                                                  text_color3),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              '${DateFormat('kk:mm a').format(snapshot.data.documents[index].data['departure_time'].toDate())}',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Text(
                                                              '${DateFormat('yyyy.MM.dd').format(snapshot.data.documents[index].data['departure_time'].toDate())}',
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  buildRowInfo('集合點  ',
                                                      '${snapshot.data.documents[index].data['departure_location']}'),
                                                  buildRowInfo('出發到  ',
                                                      '${snapshot.data.documents[index].data['destination_location']}'),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '${snapshot.data.documents[index].data['users'].length}/${snapshot.data.documents[index].data['maxPoolers']}',
                                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                                              )
                                          ],
                                        ),
                                      ],
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                ),
              );
            }),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // floatingActionButton: FadeTransition(
        //   opacity: _hideFabController,
        //   child: ScaleTransition(
        //     scale: _hideFabController,
        //     child: widget.inGroupFetch
        //         ? !widget.inGroup
        //             ? Padding(
        //                 padding: const EdgeInsets.fromLTRB(0, 20, 0, 80),
        //                 child: FloatingActionButton(
        //                   onPressed: () => widget.startCreatingTrip(context),
        //                   child: Tooltip(
        //                     message: 'Create Group',
        //                     verticalOffset: -60,
        //                     child: Icon(Icons.add),
        //                   ),
        //                 ),
        //               )
        //             : Padding(
        //                 padding: const EdgeInsets.fromLTRB(0, 20, 0, 80),
        //                 child: FloatingActionButton.extended(
        //                   onPressed: () {
        //                     Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                             builder: (context) => GroupPage()));
        //                   },
        //                   icon: Icon(Icons.group),
        //                   label: Text('Group'),
        //                 ),
        //               )
        //         : null,
        //   ),
        // )
        
        );
  }
}
