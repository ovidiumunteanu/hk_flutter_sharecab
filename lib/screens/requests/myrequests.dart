import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/screens/groupdetailscreen/ended_group_details.dart';
import 'package:shareacab/screens/rootscreen.dart';

class MyRequests extends StatefulWidget {
  @override
  _MyRequestsState createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> with AutomaticKeepAliveClientMixin<MyRequests> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future getOldTrips() async {
    var user = await auth.currentUser();
    final userid = user.uid;
    var qn = await Firestore.instance.collection('group').where('users', arrayContains: userid).orderBy('end', descending: true).getDocuments();
    return qn.documents;
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
    super.build(context);
    final currentuser = Provider.of<FirebaseUser>(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => RootScreen()));
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ended rides'),
        ),
        body: Container(
            child: StreamBuilder(
                stream: Firestore.instance.collection('userdetails').document(currentuser.uid).snapshots(),
                builder: (context, usersnapshot) {
                  return FutureBuilder(
                    future: getOldTrips(),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                            itemBuilder: (ctx, index) {
                              final destination = snapshot.data[index].data['destination'];
                              final start = DateTime.now();
                              final end = DateTime.now(); //snapshot.data[index].data['end'].toDate();
                              final docId = snapshot.data[index].documentID;
                              final privacy = snapshot.data[index].data['privacy'];
                              final numberOfMembers = snapshot.data[index].data['numberOfMembers'];
                              final data = snapshot.data[index];
                              return Hero(
                                tag: Text(docId),
                                child: (docId != usersnapshot.data['currentGroup'])
                                    ? Card(
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        elevation: 0.0,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EndedGroupDetails(destination, docId, privacy, start, end, numberOfMembers, data)));
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
                                            elevation: 5,
                                            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: <Widget>[
                                                    buildRowInfo('Destination : ', '${snapshot.data[index].data['destination']}'),
                                                    buildRowInfo('Destination Location : ', '${snapshot.data[index].data['destination_location']}'),
                                                    buildRowInfo('Departure Date : ', '${DateFormat('yyyy.MM.dd').format(snapshot.data[index].data['departure_time'].toDate())}'),
                                                    buildRowInfo('Departure Time : ', '${DateFormat('kk:mm a').format(snapshot.data[index].data['departure_time'].toDate())}'),
                                                    buildRowInfo('Departure Location : ', '${snapshot.data[index].data['departure_location']}'),
                                                    buildRowInfo('Rule : ', '${snapshot.data[index].data['rule']} , ${snapshot.data[index].data['sex']}'),
                                                    buildRowInfo('Number of people who joined : ', '${snapshot.data[index].data['maxPoolers']}'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Card(),
                              );
                            });
                      }
                    },
                  );
                })),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
