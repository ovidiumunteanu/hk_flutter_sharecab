import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/components/TripItem.dart';
import 'package:shareacab/utils/constant.dart';
import 'groupdetailscreen/groupdetails.dart';
import 'groupscreen/group.dart';

class TripsList extends StatefulWidget {
  final bool inGroupFetch;
  final bool inGroup;
  final filterDeparture;
  final filterDestination;
  final filterDepartureSub;
  final filterDestinationSub;
  final filterGender;
  final sortTime;
  final Function startCreatingTrip;
  TripsList(this.filterDeparture, this.filterDepartureSub, this.filterDestination, this.filterDestinationSub, this.filterGender, this.sortTime,
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

  var currentGroup ;

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

  Stream<QuerySnapshot> getStream() {
    var query =
        Firestore.instance.collection('group').where('end', isEqualTo: false);
    if (widget.filterDeparture != '任何') {
      query = query.where('departure', isEqualTo: widget.filterDeparture);
    }
    if (widget.filterDestination != '任何') {
      query = query.where('destination', isEqualTo: widget.filterDestination);
    }
    if (widget.filterDepartureSub != '任何') {
      query = query.where('departure_sub', isEqualTo: widget.filterDepartureSub);
    }
    if (widget.filterDestinationSub != '任何') {
      query = query.where('destination_sub', isEqualTo: widget.filterDestinationSub);
    }
    if (widget.filterGender != '任何') {
      query = query.where('sex', isEqualTo: widget.filterGender);
    }
 
    if (widget.sortTime == '最早' || widget.sortTime == '任何') {
      query = query.orderBy('created', descending: true);
    } else if (widget.sortTime == '最遲') {
      query = query.orderBy('created', descending: false);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final currentuser = Provider.of<FirebaseUser>(context);
    return Scaffold(
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('userdetails')
              .document(currentuser == null ? '' : currentuser.uid)
              .snapshots(),
          builder: (_, usersnapshot) {
            if (usersnapshot.connectionState == ConnectionState.waiting) {
              Center(child: CircularProgressIndicator());
            }
            if (usersnapshot.connectionState == ConnectionState.active && usersnapshot.data != null) {
              requestsArray = usersnapshot.data['currentGroupJoinRequests'];
              requestsArray ??= [];

              currentGroup = usersnapshot.data['currentGroup'];
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
                stream: getStream(),
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
                        final docData = snapshot.data.documents[index];
                        final docId = docData.documentID;

                        final transportation = docData.data['transportation'];
                        final departure = docData.data['departure'];
                        final destination = docData.data['destination'];
                        final departure_sub = docData.data['departure_sub'];
                        final destination_sub = docData.data['destination_sub'];
                        final departure_location =
                            docData.data['departure_location'];
                        final destination_location =
                            docData.data['destination_location'];
                        final departure_time = docData.data['departure_time'];
                        final maxMembers = docData.data['maxMembers']; 
                        final reference_number = docData.data['reference_number']; 
                        final covid = docData.data['covid']; 
                        var joinedMember = 0;
                        for (var i = 0;
                            i < docData.data['users'].length;
                            i++) {
                          joinedMember = joinedMember +
                              docData.data['users'][i]['num'];
                        }

                        if (docId == currentGroup) {
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
                                        builder: (context) =>
                                            GroupDetails(docId, isHistory: false,)));
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 0),
                                child: TripItem(
                                  transportation: transportation,
                                  departureSub:
                                      departure_sub, // snapshot.data.documents[index].data['departure'],
                                  destinationSub:
                                      destination_sub, //snapshot.data.documents[index].data['destination'],
                                  departure_loc: departure_location,
                                  destination_loc: destination_location,
                                  departure_time: departure_time.toDate(),
                                  maxMember: maxMembers,
                                  joinedMember: joinedMember,
                                  reference_number: reference_number,
                                  covid: covid,
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
