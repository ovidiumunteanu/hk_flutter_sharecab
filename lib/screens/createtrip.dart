import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shareacab/components/TopMessage.dart';
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
    TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: text_color1);
TextStyle optionTxt =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: text_color1);
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
  List<String> max_members = ['2位', '3位', '4位', '5位'];
  List<String> cur_members = ['1位', '2位', '3位'];

  String _covid;
  String _transportation = '的士';
  String _departure = '香港島';
  String _departure_sub;
  String _destination = '香港島';
  String _destination_sub;
  String _departure_location;
  String _destination_location;
  DateTime _selectedDepartureDate;
  TimeOfDay _selectedDepartureTime;
  int _maxMembers = 2;
  int _curMembers = 1;
  String _sex = '男女也可';
  String _tunnel = '可以經隧道';
  int _waiting_time = 0;
  bool _wait_all_member = false;

  void _addNewRequest() async {
    // _departure_location = departure_loc_ctr.text;
    // _destination_location = destination_loc_ctr.text;

    final newRq = RequestDetails(
      id: DateTime.now().toString(),
      name: 'Name',
      transportation: _transportation,
      departure: _departure,
      departure_sub: _departure_sub,
      destination: _destination,
      destination_sub: _destination_sub,
      departure_location: _departure_location,
      destination_location: _destination_location,
      departureDate: _selectedDepartureDate,
      departureTime: _selectedDepartureTime,
      maxMembers: _maxMembers,
      curMembers: _curMembers,
      covid: _covid,
      sex: _sex,
      tunnel: _tunnel,
      reference_number:
          '#AA${(DateTime.now().millisecondsSinceEpoch / 1000).toInt()}',
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

    if (_departure == '' ||
        _departure_sub == '' ||
        _destination == '' ||
        _destination_sub == '' ||
        _destination_location == '' ||
        _departure_location == '') {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: yellow_color2,
        content: Text('請輸入相關資料。', style: TextStyle(color: text_color1)),
      ));
      return; //return stops function execution and thus nothing is called or returned
    } else if (_selectedDepartureDate == null ||
        _selectedDepartureTime == null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: yellow_color2,
        content: Text('請輸入相關資料。', style: TextStyle(color: text_color1)),
      ));
      return;
    } else if (_maxMembers < _curMembers) {
       _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: yellow_color2,
        content: Text('最大成員數應大於當前成員數', style: TextStyle(color: text_color1)),
      ));
      return;
    }
    else {
      // _formKey.currentState.save();
      FocusScope.of(context).unfocus();
      _addNewRequest();

      departure_loc_ctr.text = '';
      destination_loc_ctr.text = '';

      widget.setTabChange(0);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buildTotalMembersInput() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '這團組多少人？ ',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: text_color1),
                ),
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: grey_color5,
                    ))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10, right: 6),
                          child: Icon(
                            Icons.person,
                            color: text_color1,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: DropdownInput(
                            hasLabel: false,
                            hasBorder: false,
                            labelStyle: TextStyle(
                                fontSize: 14,
                                color: text_color1,
                                fontWeight: FontWeight.bold),
                            hint: '請選擇',
                            curItem: '$_maxMembers位',
                            items: max_members,
                            onChange: (newValue) {
                              _maxMembers = int.parse(newValue[0]);
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentMembersInput() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已有多少位乘客(包括自己)？  ',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: text_color1),
                ),
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: grey_color5,
                    ))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10, right: 6),
                          child: Icon(
                            Icons.person,
                            color: text_color1,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: DropdownInput(
                            hasLabel: false,
                            hasBorder: false,
                            labelStyle: TextStyle(
                                fontSize: 14,
                                color: text_color1,
                                fontWeight: FontWeight.bold),
                            hint: '請選擇',
                            curItem: '$_curMembers位',
                            items: cur_members,
                            onChange: (newValue) {
                              _curMembers = int.parse(newValue[0]);
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ],
                    )),
                Text(
                  '* 三歲或以上為一位乘客。',
                  style: TextStyle(
                      height: 2, fontSize: 14, color: Color(0xFF808C95)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCovidInput() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '團友必須已注射新冠疫苗',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: text_color1),
                ),
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: grey_color5,
                    ))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10, right: 6),
                          child: Image.asset(
                            'assets/images/covid.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: DropdownInput(
                            hasLabel: false,
                            hasBorder: false,
                            labelStyle: TextStyle(
                                fontSize: 14,
                                color: text_color1,
                                fontWeight: FontWeight.bold),
                            hint: '請選擇',
                            curItem: _covid,
                            items: covid_list,
                            onChange: (newValue) {
                              _covid = newValue;
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFrom() {
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
      child: Row(
        children: [
          Expanded(
              child: DropdownInput(
            label: '出發點 1',
            labelStyle: TextStyle(
                fontSize: 14, color: text_color1, fontWeight: FontWeight.bold),
            hint: '請選擇',
            curItem: _departure,
            items: location_list1,
            onChange: (newValue) {
              _departure_sub = location_list2[newValue][0];
              _departure = newValue;
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )),
          SizedBox(
            width: 12,
          ),
          Expanded(
              child: DropdownInput(
            label: '出發點 2',
            labelStyle: TextStyle(
                fontSize: 14, color: text_color1, fontWeight: FontWeight.bold),
            hint: '請選擇',
            curItem: _departure_sub,
            items: location_list2[_departure],
            onChange: (newValue) {
              _departure_sub = newValue;
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )),
        ],
      ),
    );
  }

  Widget buildTo() {
    print('_destination ' + _destination);
    print(location_list2[_destination]);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: grey_color2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
              child: DropdownInput(
            label: '目的地 1',
            labelStyle: TextStyle(
                fontSize: 14, color: text_color1, fontWeight: FontWeight.bold),
            hint: '請選擇',
            curItem: _destination,
            items: location_list1,
            onChange: (newValue) {
              _destination_sub = location_list2[newValue][0];
              _destination = newValue;
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )),
          SizedBox(
            width: 12,
          ),
          Expanded(
              child: DropdownInput(
            label: '目的地 2',
            labelStyle: TextStyle(
                fontSize: 14, color: text_color1, fontWeight: FontWeight.bold),
            hint: '請選擇',
            curItem: _destination_sub,
            items: location_list2[_destination],
            onChange: (newValue) {
              _destination_sub = newValue;
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )),
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
            '哪裡集合？（需要明確說明） ',
            style: TextStyle(
                fontSize: 14, color: text_color1, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 4),
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
            '例如：屋苑 / 街道 / 大廈 / 商場 / 地鐵站 ',
            style: hintTxt,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            '去哪裡？',
            style: TextStyle(
                fontSize: 14, color: text_color1, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 4),
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
            '例如：屋苑 / 街道 / 大廈 / 商場 / 地鐵站 ',
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
        ],
      ),
    );
  }

  Widget buildBottomBtn(currentuser) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('userdetails')
            .document(currentuser == null ? '' : currentuser.uid)
            .snapshots(),
        builder: (context, usersnapshot) {
          if (usersnapshot.connectionState == ConnectionState.active) {
            var groupUID = usersnapshot.data['currentGroup'];
            return BottomCreateTripBtn(groupUID == null, () {
              SystemChannels.textInput.invokeMethod('Text Input hide');
              _submitData();
            });
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
        // FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(context, _auth, currentuser),
        body: Builder(builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            //padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Column(
              children: [
                TopMessage(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          buildTotalMembersInput(),
                          buildCurrentMembersInput(),
                          buildCovidInput(),
                          RadioInput('選擇坐？', ['的士', 'Uber'], _transportation,
                              (val) {
                            _transportation = val;
                          }),
                          SizedBox(
                            height: 8,
                          ),
                          buildFrom(),
                          buildTo(),
                          buildDetailInfo(),
                          RadioInput('團友性別', ['男女也可', '只限男性', '只限女性'], _sex,
                              (val) {
                            _sex = val;
                          }),
                          RadioInput('經隧道？（如果有）', ['可以', '不可以'], '可以', (val) {
                            if (val == '可以') {
                              _tunnel = '可以經隧道';
                            } else {
                              _tunnel = '不會經隧道';
                            }
                          }),
                          RadioInput('會準時出發？', ['是 (不會等待)', '不是 (有權等待上限10分鐘)'],
                              '是 (不會等待)', (val) {
                            if (val == '是 (不會等待)') {
                              _wait_all_member = false;
                            } else {
                              _wait_all_member = true;
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
