import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/models/alltrips.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:shareacab/screens/createtrip.dart';
import 'package:shareacab/screens/filter.dart';
import 'package:shareacab/screens/help.dart';
import 'package:shareacab/screens/settings.dart';
import 'package:shareacab/screens/tripslist.dart';
import 'package:shareacab/services/auth.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

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

  @override
  Widget build(BuildContext context) {
    var fetched = false;
    super.build(context);
    final currentuser = Provider.of<FirebaseUser>(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: <Widget>[
          FlatButton.icon(
            textColor: getVisibleColorOnPrimaryColor(context),
            icon: Icon(
              Icons.filter_list,
              size: 30.0,
            ),
            onPressed: () async {
              _startFilter(context);
            },
            label: Text('Filter'),
          ),
          IconButton(
            icon: Icon(Icons.help),
            tooltip: 'Help',
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Help()));
            },
          ),
          IconButton(
              icon: Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                return Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return Settings(_auth);
                }));
              }),
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
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 8),
                        child: Text('Your current location : ',
                            style: TextStyle(
                              fontSize: 18,
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              _address,
                              style: TextStyle(
                                fontSize: 14,
                                color: getVisibleTextColorOnScaffold(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(5),
                        height: (MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top) *
                            0.79,
                        width: double.infinity,
                        child: TripsList(
                          _dest,
                          _selecteddest,
                          _notPrivacy,
                          inGroup: inGroup,
                          inGroupFetch: inGroupFetch,
                          startCreatingTrip: _startCreatingTrip,
                        ),
                      ),
                    ],
                  ),
                ),
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
