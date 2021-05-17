import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';

class MapView extends StatefulWidget {
  final String location;

  MapView(this.location);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView>
    with AutomaticKeepAliveClientMixin<MapView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    getCoordinates();
  }

  void setCustomMapPin() async {
    var tmp_marker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/marker_icon.png');
    setState(() {
      pinLocationIcon = tmp_marker;
    });
  }

  void getCoordinates() async {
    try {
      final query = widget.location;
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      var first = addresses.first;
      await _goToLocation( first.coordinates.latitude, first.coordinates.longitude);
      // print('${first.featureName} : ${first.coordinates}');
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId('departure_location'),
            position:
                LatLng(first.coordinates.latitude, first.coordinates.longitude),
            icon: pinLocationIcon,
            infoWindow: InfoWindow(
                title: 'Departure Location', snippet: widget.location)));
      });
    } 
    catch (err) {
      print(err.toString());
      String errStr = err.message ?? err.toString();
      final snackBar = SnackBar(content: Text('Invalid location!'), duration: Duration(seconds: 3));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  Future<void> _goToLocation(double lat, double lon) async {
    var cameraPosition = CameraPosition(
      //  bearing: 192.8334901395799,
      target: LatLng(lat, lon),
      //  tilt: 59.440717697143555,
      zoom: 19.4746,
    );
    final controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.location),
      ),
      body: Builder(builder: (BuildContext context) {
        return Container(
            //padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: GoogleMap(
          mapType: MapType.hybrid,
          markers: _markers,
          initialCameraPosition: CameraPosition(
            target: LatLng(37.42796133580664, -122.085749655962),
            zoom: 19.4746,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ));
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
