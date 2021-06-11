import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/models/alltrips.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:shareacab/screens/createtrip.dart';
import 'package:shareacab/screens/filter.dart';
import 'package:shareacab/screens/help.dart';
import 'package:shareacab/screens/settings.dart';
import 'profile/userprofile.dart';
import 'package:shareacab/screens/tripslist.dart';
import 'package:shareacab/services/auth.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool _dest = false;
  bool _notPrivacy = false;
  String _selecteddest;
  bool inGroup = false;

  LocationData _currentPosition;
  String _address = '';
  Location location = Location();

  void getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    var coord = await location.getLocation();
    await _getAddress(coord.latitude, coord.longitude).then((value) {
      setState(() {
        _address = '${value.first.addressLine}';
      });
    });
    // location.onLocationChanged().listen((LocationData currentLocation) {
    //   print('${currentLocation.longitude} : ${currentLocation.longitude}');
    //  _getAddress(currentLocation.latitude, currentLocation.longitude)
    //         .then((value) {
    //       setState(() {
    //         _address = "${value.first.addressLine}";
    //       });
    //     });
    // });
  }

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }

  void _filteredList(destination, dest, priv) {
    setState(() {
      _notPrivacy = priv;
      _dest = destination;
      _selecteddest = dest;
    });
  }

  void _startFilter(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return Filter(_filteredList, _dest, _selecteddest, _notPrivacy);
      },
    );
  }

  void _startCreatingTrip(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamed(
      CreateTrip.routeName,
    );
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  var inGroupFetch = false;
  var UID;
  Future getCurrentUser() async {
    var user = await auth.currentUser();
    final userid = user.uid;
    setState(() {
      UID = userid;
    });
  }

  var currentGroup;
  @override
  void initState() {
    inGroupFetch = false;
    super.initState();
    getCurrentUser();
    getLoc();
  }

  String curDeparture = 'ANY';
  String curDestination = 'ANY';
  String sortbyTime = 'ANY';

  Widget filterBtn(List<String> items, String type) {
    var curValue = curDeparture;
    if (type == 'destination') {
      curValue = curDestination;
    } else if (type == 'sortbytime') {
      curValue = sortbyTime;
    }

    return DropdownButton<String>(
      value: curValue,
      // icon: const Icon(Icons.arrow_downward),
      iconSize: 15,
      elevation: 16,
      style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: text_color2),
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
        } else {
          setState(() {
            curDeparture = newValue;
          });
        }
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget filterView() {
    var dest_list = ['ANY'];
    var dep_list = ['ANY'];
    dest_list.insertAll(1, destination_list);
    dep_list.insertAll(1, departure_list);

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
              Text('離開'),
              filterBtn(dep_list, 'departure')
            ],
          )),
          Container(
            width: 40,
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
            width: 40,
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
              Text('按時間排序'),
              filterBtn(['ANY', '最近的', '最老'], 'sortbytime')
            ],
          )),
        ],
      ),
    );
  }

  void logout() async {
    ProgressDialog pr;
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: '註銷...',
      backgroundColor: Theme.of(context).backgroundColor,
      messageTextStyle: TextStyle(color: Theme.of(context).accentColor),
    );
    await pr.show();
    await Future.delayed(Duration(
        seconds:
            1)); // sudden logout will show ProgressDialog for a very short time making it not very nice to see :p
    try {
      await _auth.signOut();
      await pr.hide();
    } catch (err) {
      await pr.hide();
      String errStr = err.message ?? err.toString();
      final snackBar =
          SnackBar(content: Text(errStr), duration: Duration(seconds: 3));
      scaffoldKey.currentState.showSnackBar(snackBar);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var fetched = false;
    super.build(context);
    final currentuser = Provider.of<FirebaseUser>(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: yellow_color2,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 35,
              height: 40,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'AA制車資',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: text_color1),
            ),
          ],
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(
          //     Icons.filter_list,
          //     color: text_color1,
          //     size: 30.0,
          //   ),
          //   tooltip: 'Filter',
          //   onPressed: () async {
          //     _startFilter(context);
          //   },
          // ),
          // IconButton(
          //   icon: Icon(
          //     Icons.help,
          //     color: text_color1,
          //   ),
          //   tooltip: 'Help',
          //   onPressed: () {
          //     Navigator.push(
          //         context, MaterialPageRoute(builder: (context) => Help()));
          //   },
          // ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.signOutAlt,
              color: text_color1,
            ),
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text('登出'),
                      content: Text('您確定要退出嗎？'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('登出',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor)),
                          onPressed: () {
                            logout();
                          },
                        ),
                        FlatButton(
                          child: Text('取消',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            },
          ),
          // IconButton(
          //     icon: Icon(
          //       Icons.person,
          //       color: text_color1,
          //     ),
          //     tooltip: '帳戶',
          //     onPressed: () {
          //       return Navigator.push(context,
          //           MaterialPageRoute(builder: (context) {
          //         return MyProfile(_auth);
          //       }));
          //     }),
        ],
      ),
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
                            height: (MediaQuery.of(context).size.height - 260),
                            width: double.infinity,
                            child: TripsList(
                              curDeparture,
                              curDestination,
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
