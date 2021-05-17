import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
          padding: const EdgeInsets.only(top: 10.0, left: 12),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
                fontSize: 16,
                // fontWeight: FontWeight.bold,
              ),
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
                                  shape: flag
                                      ? RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25.0)),
                                          side: BorderSide(
                                              color:
                                                  Theme.of(context).accentColor,
                                              width: 2.0),
                                        )
                                      : requestsArray.contains(docId)
                                          ? RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0)),
                                              side: BorderSide(
                                                  color: Colors.pink[300],
                                                  width: 2.0),
                                            )
                                          : RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0)),
                                            ),
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 5),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          buildRowInfo('Destination : ', '${snapshot.data.documents[index].data['destination']}'),
                                          buildRowInfo('Destination Location : ', '${snapshot.data.documents[index].data['destination_location']}'),
                                          buildRowInfo('Departure Date : ', '${DateFormat('yyyy.MM.dd').format(snapshot.data.documents[index].data['departure_time'].toDate())}'),
                                          buildRowInfo('Departure Time : ', '${DateFormat('kk:mm a').format(snapshot.data.documents[index].data['departure_time'].toDate())}'),
                                          buildRowInfo('Departure Location : ', '${snapshot.data.documents[index].data['departure_location']}'),
                                          buildRowInfo('Rule : ', '${snapshot.data.documents[index].data['rule']} , ${snapshot.data.documents[index].data['sex']}'),
                                          buildRowInfo('Number of people who joined : ', '${snapshot.data.documents[index].data['maxPoolers']}'),
                                        ],
                                      ),
                                    ),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FadeTransition(
          opacity: _hideFabController,
          child: ScaleTransition(
            scale: _hideFabController,
            child: widget.inGroupFetch
                ? !widget.inGroup
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 80),
                        child: FloatingActionButton(
                          onPressed: () => widget.startCreatingTrip(context),
                          child: Tooltip(
                            message: 'Create Group',
                            verticalOffset: -60,
                            child: Icon(Icons.add),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 80),
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GroupPage()));
                          },
                          icon: Icon(Icons.group),
                          label: Text('Group'),
                        ),
                      )
                : null,
          ),
        ));
  }
}
