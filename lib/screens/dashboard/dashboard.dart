import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/components/TopMessage.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/models/alltrips.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:shareacab/providers/homesearch.dart';
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

  TextEditingController _controller = TextEditingController();
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
  String search = '';

  @override
  Widget build(BuildContext context) {
    var fetched = false;
    super.build(context);
    final currentuser = Provider.of<FirebaseUser>(context);
    return ChangeNotifierProvider<HomeSearchProvider>(
      create: (_) => HomeSearchProvider(),
      child: Scaffold(
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
                    Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          height: 42,
                          decoration: BoxDecoration(
                              color: Color(0xFFf7f7f7),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: TextFormField(
                            controller: _controller,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: text_color1),
                            decoration: InputDecoration(
                                icon: Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.search),
                                ),
                                hintText: '請輸入搜尋[前往]關鍵字',
                                hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF808080)),
                                border: InputBorder.none),
                            onChanged: (value) {
                              Provider.of<HomeSearchProvider>(context,
                                      listen: false)
                                  .setSearch(_controller.text);
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        )),
                    FilterView((_departure, _departure_sub, _destination,
                            _destination_sub, _curGender, _sortbyTime) {
                      print(
                          '$_departure, $_departure_sub, $_destination, $_destination_sub, $_curGender, $_sortbyTime');
                      setState(() {
                        curDeparture = _departure;
                        curDepartureSub = _departure_sub;
                        curDestination = _destination;
                        curDestinationSub = _destination_sub;
                        curGender = _curGender;
                        sortbyTime = _sortbyTime;
                      });
                    }, curDeparture, curDepartureSub, curDestination,
                        curDestinationSub, curGender, sortbyTime),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Container(
                              // margin: EdgeInsets.all(5),
                              height:
                                  (MediaQuery.of(context).size.height - 240),
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
                                search: _controller.text,
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
