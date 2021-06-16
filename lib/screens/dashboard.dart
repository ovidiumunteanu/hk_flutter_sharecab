import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/models/alltrips.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:shareacab/screens/createtrip.dart';
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
  String curGender = '任何';
  String sortbyTime = '任何';

  Widget filterBtn(List<String> items, String type) {
    var curValue = curDeparture;
    if (type == 'destination') {
      curValue = curDestination;
    } else if (type == 'sortbytime') {
      curValue = sortbyTime;
    } else if (type == 'gender') {
      curValue = curGender;
    }
    return Container(
      child: DropdownButton<String>(
        value: curValue,
        icon: null,
        iconSize: 0,
        elevation: 16,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: text_color2),
        underline: Container(
          height: 0,
        ),
        onChanged: (String newValue) {
          if (type == 'destination') {
            setState(() {
              curDestination = newValue;
            });
          } else if (type == 'sortbytime') {
            setState(() {
              sortbyTime = newValue;
            });
          } else if (type == 'departure') {
            setState(() {
              curDeparture = newValue;
            });
          } else {
            setState(() {
              curGender = newValue;
            });
          }
        },
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child:  Container(
              width: MediaQuery.of(context).size.width / 4 - 20, 
              // color: red_color1,
              child: Text(value,  textAlign: TextAlign.center,),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget filterView() {
    var dest_list = ['任何'];
    var dep_list = ['任何'];
    dest_list.insertAll(1, location_list);
    dep_list.insertAll(1, location_list);

    return Container(
      width: double.infinity,
      // height: 60,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
              child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Text('所在地'),
              filterBtn(dep_list, 'departure')
            ],
          )),
          Container(
            width: 20,
            child: SvgPicture.asset(
              'assets/svgs/vert_divider.svg',
            ),
          ),
          Expanded(
              child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Text('目的地'),
              filterBtn(dest_list, 'destination')
            ],
          )),
          Container(
            width: 20,
            child: SvgPicture.asset(
              'assets/svgs/vert_divider.svg',
            ),
          ),
          Expanded(
              child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Text('團友性別'),
              filterBtn(['任何', '只限男性', '只限女性'], 'gender')
            ],
          )),
          Container(
            width: 20,
            child: SvgPicture.asset(
              'assets/svgs/vert_divider.svg',
            ),
          ),
          Expanded(
              child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Text('出發時間'),
              filterBtn(['任何', '最近', '最遠'], 'sortbytime')
            ],
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var fetched = false;
    super.build(context);
    final currentuser = Provider.of<FirebaseUser>(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(context, _auth),
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('userdetails')
            .document(currentuser.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
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
            if (snapshot.connectionState == ConnectionState.active &&
                fetched == true) {
              return Scaffold(
                body: Column(children: <Widget>[
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
                  filterView(),
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
                              curDestination,
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
