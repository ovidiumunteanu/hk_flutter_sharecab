import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/services/trips.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/components/appbar.dart';
import 'package:shareacab/utils/constant.dart';

TextStyle descTxt =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: text_color2);
TextStyle optionTxt =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text_color1);
TextStyle hintTxt =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: text_color3);

class CreateTrip extends StatefulWidget {
  final Function setTabChange;
  static const routeName = '/createTrip';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  CreateTrip(this.setTabChange);

  @override
  _CreateTripState createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip>
    with AutomaticKeepAliveClientMixin<CreateTrip> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RequestService _request = RequestService();
  final AuthService _auth = AuthService();

  final departure_loc_ctr = TextEditingController();
  final destination_loc_ctr = TextEditingController();

  bool hasGroup = false;
  List<String> members = ['1', '2', '3'];

  String _transportation = '的士';
  String _departure = location_list[0];
  String _destination = location_list[1];
  String _departure_location;
  String _destination_location;
  DateTime _selectedDepartureDate;
  TimeOfDay _selectedDepartureTime;
  int _maxMembers = 1;
  String _sex = '男女也可';
  String _tunnel = '行隧道';
  int _waiting_time = 0;
  bool _wait_all_member = true;

  void _addNewRequest() async {
    // _departure_location = departure_loc_ctr.text;
    // _destination_location = destination_loc_ctr.text;

    final newRq = RequestDetails(
      id: DateTime.now().toString(),
      name: 'Name',
      transportation: _transportation,
      departure: _departure,
      destination: _destination,
      departure_location: _departure_location,
      destination_location: _destination_location,
      departureDate: _selectedDepartureDate,
      departureTime: _selectedDepartureTime,
      maxMembers: _maxMembers,
      sex: _sex,
      tunnel: _tunnel,
      waiting_time: _waiting_time,
      wait_all_member: _wait_all_member,
    );
    try {
      await _request.createTrip(newRq);
      // LOOK FOR A WAY TO SHOW A RESPONSE THAT THE TRIP HAS BEEN CREATED
      // _scaffoldKey.currentState.hideCurrentSnackBar();
      // await _scaffoldKey.currentState.showSnackBar(SnackBar(
      //   duration: Duration(seconds: 1),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   content: Text('Your Trip has been created', style: TextStyle(color: Theme.of(context).accentColor)),
      // ));
    } catch (e) {
      print(e.toString());
      //String errStr = e.message ?? e.toString();
      //final snackBar = SnackBar(content: Text(errStr), duration: Duration(seconds: 3));
      //_scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void _submitData() {
    _formKey.currentState.validate();

    // _departure_location = departure_loc_ctr.text;
    // _destination_location = destination_loc_ctr.text;

    if (_destination == null ||
        _destination_location == null ||
        _departure_location == null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: yellow_color2,
        content: Text('One or more fields is missing',
            style: TextStyle(color: text_color1)),
      ));
      return; //return stops function execution and thus nothing is called or returned
    } else if (_selectedDepartureDate == null ||
        _selectedDepartureTime == null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: yellow_color2,
        content: Text('Date or Time is missing',
            style: TextStyle(color: text_color1)),
      ));
      return;
    } else {
      // _formKey.currentState.save();
      FocusScope.of(context).unfocus();
      _addNewRequest();

      departure_loc_ctr.text = '';
      destination_loc_ctr.text = '';
      // setState(() {
      //   _transportation = '的士';
      //   _departure = location_list[0];
      //   _destination = location_list[1];
      //   _departure_location = null;
      //   _destination_location = null;
      //   _maxMembers = 1;
      //   _sex = '男女也可';
      //   _tunnel = '行隧道';
      //   _waiting_time = 0;
      //   _wait_all_member = true;
      // });

      widget.setTabChange(0);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buildFromTo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: grey_color2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownInput(
            label: '所在地',
            curItem: _departure,
            items: location_list,
            onChange: (newValue) {
              // setState(() {
              //   _departure = newValue;
              // });
              _departure = newValue;
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          SizedBox(
            height: 12,
          ),
          DropdownInput(
            label: '目的地',
            curItem: _destination,
            items: location_list,
            onChange: (newValue) {
              // setState(() {
              //   _destination = newValue;
              // });
              _destination = newValue;
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ],
      ),
    );
  }

  Widget buildDetailInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12),
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '您會去哪裡？ （請明確說明目的地）',
            style: descTxt,
          ),
          Container(
            child: TextFormField(
              // controller: destination_loc_ctr,
              // decoration: InputDecoration(
              //     // hintText: 'Destination Location',
              //     ),
              validator: (val) => val.length == 0 ? '輸入目的地位置。' : null,
              onChanged: (val) {
                _destination_location = val;
                // FocusScope.of(context).requestFocus(FocusNode());
                // setState(() => _destination_location = val);
              },
            ),
          ),
          Text(
            '例如：元朗西地鐵站, YOHO MALL 附近',
            style: hintTxt,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            '您會想在哪裡與團友集合？（請明確說明集合地點）',
            style: descTxt,
          ),
          Container(
            child: TextFormField(
              // controller: departure_loc_ctr,
              // decoration: InputDecoration(
              //     // hintText: 'Departure Location',
              //     ),
              validator: (val) => val.length == 0 ? '輸入出發地點。' : null,
              onChanged: (val) {
                _departure_location = val;
                // FocusScope.of(context).requestFocus(FocusNode());
                // setState(() => _departure_location = val);
              },
            ),
          ),
          Text(
            '例如：觀塘APM, 滙豐銀行 ',
            style: hintTxt,
          ),
          SizedBox(
            height: 20,
          ),
          DateTimeInput((val) {
            _selectedDepartureDate = val;
          }, (val) {
            _selectedDepartureTime = val;
          }),
          SizedBox(
            height: 20,
          ),
          Container(
            child: DropdownInput(
              label: '您現在已經有多少乘客在一起？(包括您自己本人)',
              curItem: _maxMembers.toString(),
              items: members,
              onChange: (newValue) {
                // setState(() => _maxMembers = int.parse(newValue));
                _maxMembers = int.parse(newValue);
                // FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
          ),
          Text(
            '* 四歲或四歲以上為一位乘客。',
            style: hintTxt,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget buildBottomBtn(currentuser) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('userdetails')
            .document(currentuser.uid)
            .snapshots(),
        builder: (context, usersnapshot) {
          if (usersnapshot.connectionState == ConnectionState.active) {
            var groupUID = usersnapshot.data['currentGroup'];
            if (groupUID != null) {
              return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom:  (Platform.isIOS ? 80 : 55)),
                  height: 55,
                  color: grey_color6,
                  child: Center(
                    child: Text('您目前已經有群組了。',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: text_color2)),
                  ));
            } else {
              return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: (Platform.isIOS ? 80 : 55)),
                  child: FlatButton(
                    padding: EdgeInsets.all(20),
                    color: yellow_color1,
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('Text Input hide');
                      _submitData();
                    },
                    child: Text('按此建立群組',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: text_color2)),
                  ));
            }
          } else {
            return Container();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var currentuser = Provider.of<FirebaseUser>(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(context, _auth),
        body: Builder(builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            //padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Column(
              children: [
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RadioInput('您會選擇坐？', ['的士', 'Uber'], _transportation,
                              (val) {
                            _transportation = val;
                          }),
                          SizedBox(
                            height: 8,
                          ),
                          buildFromTo(),
                          buildDetailInfo(), 
                          RadioInput('團友性別', ['男女也可', '只限男性', '只限女性'], _sex,
                              (val) {
                            _sex = val;
                          }),
                          RadioInput('會行隧道嗎？（如果有）', ['會', '不會'], '會', (val) {
                            if (val == '會') {
                              _tunnel = '行隧道';
                            } else {
                              _tunnel = '不會行隧道';
                            }
                          }),
                          RadioInput('會準時出發及不會等待任何遲到的團友？',
                              ['是 (會準時出發)', '不是 (有權等待)'], '是 (會準時出發)', (val) {
                            if (val == '是 (會準時出發)') {
                              _wait_all_member = true;
                            } else {
                              _wait_all_member = false;
                            }
                          }),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        bottomNavigationBar: buildBottomBtn(currentuser),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
