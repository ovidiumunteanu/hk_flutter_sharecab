import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/components/TopMessage.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/models/alltrips.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:shareacab/screens/createtrip.dart';
import 'package:shareacab/screens/dashboard/filterview.dart';
import 'package:shareacab/screens/tripslist.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/components/appbar.dart';
import 'package:location/location.dart';
import 'package:shareacab/utils/constant.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin<Dashboard> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  List<RequestDetails> filtered = allTrips;
  bool inGroup = false;
  Location location = Location();

  void _startCreatingTrip(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(
      CreateTrip.routeName,
    );
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  var inGroupFetch = false;

  var currentGroup;
  @override
  void initState() {
    inGroupFetch = false;
    super.initState();
  }

  String curDeparture = '任何';
  String curDestination = '任何';
  String curDepartureSub = '任何';
  String curDestinationSub = '任何';
  String curGender = '任何';
  String sortbyTime = '任何';
 
  @override
  Widget build(BuildContext context) {
    var fetched = false;
    super.build(context);
    final currentuser = Provider.of<FirebaseUser>(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(context, _auth, currentuser),
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('userdetails')
            .document(currentuser != null ? currentuser.uid : '')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          print(snapshot.data);
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.data != null) {
            var temp = snapshot.data['currentGroup'];
            if (temp != null) {
              inGroup = true;
              inGroupFetch = true;
            } else {
              inGroup = false;
              inGroupFetch = true;
            }
            fetched = true;
          }

          try {
            if (currentuser == null ||
                (snapshot.connectionState == ConnectionState.active &&
                    fetched == true)) {
              return Scaffold(
                body: Column(children: <Widget>[
                  TopMessage(),
                  FilterView((_departure, _departure_sub, _destination, _destination_sub, _curGender, _sortbyTime){
                    print('$_departure, $_departure_sub, $_destination, $_destination_sub, $_curGender, $_sortbyTime');
                    setState(() {
                      curDeparture = _departure;
                      curDepartureSub = _departure_sub;
                      curDestination = _destination;
                      curDestinationSub = _destination_sub;
                      curGender = _curGender;
                      sortbyTime = _sortbyTime;
                    });
                  }, curDeparture, curDepartureSub, curDestination, curDestinationSub, curGender, sortbyTime),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            // margin: EdgeInsets.all(5),
                            height: (MediaQuery.of(context).size.height - 240),
                            width: double.infinity,
                            child: TripsList(
                              curDeparture,
                              curDepartureSub,
                              curDestination,
                              curDestinationSub,
                              curGender,
                              sortbyTime,
                              inGroup: inGroup,
                              inGroupFetch: inGroupFetch,
                              startCreatingTrip: _startCreatingTrip,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              );
            }
          } catch (e) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}