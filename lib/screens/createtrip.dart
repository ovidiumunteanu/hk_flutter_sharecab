import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shareacab/components/buttons.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:intl/intl.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/services/trips.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/screens/help.dart';
import 'package:shareacab/screens/settings.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shareacab/utils/constant.dart';

TextStyle descTxt =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: text_color2);
TextStyle optionTxt =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text_color1);

class CreateTrip extends StatefulWidget {
  final Function setTabChange;
  static const routeName = '/createTrip';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  CreateTrip(this.setTabChange);

  @override
  _CreateTripState createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _finalDestinationController = TextEditingController();
  final RequestService _request = RequestService();
  final AuthService _auth = AuthService();

  String _transportation = 'Taxi';
  String _departure = departure_list[0];
  String _destination = destination_list[0];
  String _departure_location;
  String _destination_location;
  DateTime _selectedDepartureDate;
  TimeOfDay _selectedDepartureTime;
  int _maxMembers = 1;
  String _sex = 'Both';
  String _tunnel = 'USE TUNNEL';
  int _waiting_time = 0;
  bool _wait_all_member = false;

  void _addNewRequest() async {
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
      _formKey.currentState.save();
      FocusScope.of(context).unfocus();
      _addNewRequest();
      widget.setTabChange(0);
    }
  }

  void _startDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(Duration(days: 1)),
            lastDate: DateTime.now().add(Duration(days: 30)))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDepartureDate = pickedDate;
        FocusScope.of(context).requestFocus(FocusNode());
      });
    });
  }

  void _startTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedDepartureTime ?? TimeOfDay.now(),
    ).then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedDepartureTime = pickedTime;
        FocusScope.of(context).requestFocus(FocusNode());
      });
    });
  }

  Widget buildLabel(String label) {
    return Container(
      margin: EdgeInsets.only(
        top: 40,
        left: 40,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 25,
                color: getVisibleTextColorOnScaffold(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateTime(String point, DateTime date, TimeOfDay time,
      Function DatePicker, Function TimePicker) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Depart',
                    style: descTxt,
                  ),
                  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: grey_color5,
                      ))),
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => DatePicker(),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: text_color1,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                date == null
                                    ? ''
                                    : '${DateFormat.yMd().format(date)}',
                                style: optionTxt,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 40,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: descTxt,
                  ),
                  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: grey_color5,
                      ))),
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => TimePicker(),
                        child: Row(
                          children: [
                            Text(
                              time == null
                                  ? ''
                                  : '${time.toString().substring(10, 15)}',
                              style: optionTxt,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget CheckBoxBtn(isChecked, onSelect) {
    return InkWell(
      onTap: () {
        onSelect(!isChecked);
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: grey_color3, width: 2),
            borderRadius: BorderRadius.circular(30),
            color: isChecked ? grey_color2 : grey_color7),
        child: isChecked
            ? Icon(
                Icons.check,
                size: 18.0,
                color: grey_color4,
              )
            : Icon(
                null,
                size: 18.0,
              ),
      ),
    );
  }

  Widget buildCheckboxRow(String label, bool isChecked, onSelect) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: optionTxt,
            ),
          ),
          CheckBoxBtn(isChecked, onSelect),
        ],
      ),
    );
  }

  Widget buildTransportation() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: grey_color2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '交通',
            style: descTxt,
          ),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('Taxi', _transportation == 'Taxi', (isChecked) {
            if (isChecked) {
              setState(() {
                _transportation = 'Taxi';
              });
            }
          }),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('Uber', _transportation == 'Uber', (isChecked) {
            if (isChecked) {
              setState(() {
                _transportation = 'Uber';
              });
            }
          }),
        ],
      ),
    );
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
            label: '出發（從）',
            curItem: _departure,
            items: departure_list,
            onChange: (newValue) {
              setState(() {
                _departure = newValue;
              });
            },
          ),
          SizedBox(
            height: 12,
          ),
          DropdownInput(
            label: '目的地（至）',
            curItem: _destination,
            items: destination_list,
            onChange: (newValue) {
              setState(() {
                _destination = newValue;
              });
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
            '你去哪兒？ （請明確點）',
            style: descTxt,
          ),
          Container(
            child: TextFormField(
              decoration: InputDecoration(
                  // hintText: 'Destination Location',
                  ),
              validator: (val) => val.length == 0 ? '輸入目的地位置。' : null,
              onChanged: (val) {
                setState(() => _destination_location = val);
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            '你去哪兒？ （請明確點）',
            style: descTxt,
          ),
          Container(
            child: TextFormField(
              decoration: InputDecoration(
                  // hintText: 'Departure Location',
                  ),
              validator: (val) => val.length == 0 ? '輸入出發地點。' : null,
              onChanged: (val) {
                setState(() => _departure_location = val);
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          buildDateTime('離開', _selectedDepartureDate, _selectedDepartureTime,
              _startDatePicker, _startTimePicker),
          SizedBox(
            height: 20,
          ),
          Text(
            '你現在有多少乘客？',
            style: descTxt,
          ),
          Container(
            child: TextFormField(
              decoration: InputDecoration(
                  // hintText: 'Departure Location',
                  ),
              keyboardType: TextInputType.number,
              validator: (val) => val.length == 0 ? '輸入乘客人數' : null,
              onChanged: (val) {
                setState(() => _maxMembers = int.parse(val));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPassengerType() {
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
          Text(
            '乘客類型',
            style: descTxt,
          ),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('兩個都', _sex == 'Both', (isChecked) {
            if (isChecked) {
              setState(() {
                _sex = 'Both';
              });
            }
          }),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('只有男性', _sex == 'Only Male', (isChecked) {
            if (isChecked) {
              setState(() {
                _sex = 'Only Male';
              });
            }
          }),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('只有女性', _sex == 'Only Female', (isChecked) {
            if (isChecked) {
              setState(() {
                _sex = 'Only Female';
              });
            }
          }),
        ],
      ),
    );
  }

  Widget buildTunnel() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: grey_color2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '隧道（如有）',
            style: descTxt,
          ),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('是的', _tunnel == 'USE TUNNEL', (isChecked) {
            if (isChecked) {
              setState(() {
                _tunnel = 'USE TUNNEL';
              });
            }
          }),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('不', _tunnel == 'NO TUNNEL', (isChecked) {
            if (isChecked) {
              setState(() {
                _tunnel = 'NO TUNNEL';
              });
            }
          }),
        ],
      ),
    );
  }

  Widget buildWaitingBuffer() {
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
          Text(
            'Waiting Buffer',
            style: descTxt,
          ),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('0 minutes (No Waiting)', _waiting_time == 0,
              (isChecked) {
            if (isChecked) {
              setState(() {
                _waiting_time = 0;
              });
            }
          }),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('5 minutes', _waiting_time == 5, (isChecked) {
            if (isChecked) {
              setState(() {
                _waiting_time = 5;
              });
            }
          }),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('10 minutes', _waiting_time == 10, (isChecked) {
            if (isChecked) {
              setState(() {
                _waiting_time = 10;
              });
            }
          }),
        ],
      ),
    );
  }

  Widget buildGoWithoutWaiting() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: grey_color2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Going without waiting all passenger join',
            style: descTxt,
          ),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('是的', _wait_all_member, (isChecked) {
            if (isChecked) {
              setState(() {
                _wait_all_member = true;
              });
            }
          }),
          SizedBox(
            height: 12,
          ),
          buildCheckboxRow('不', _wait_all_member == false, (isChecked) {
            if (isChecked) {
              setState(() {
                _wait_all_member = false;
              });
            }
          }),
        ],
      ),
    );
  }

  Widget buildBottomBtn() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 55),
      child: FlatButton(
        padding: EdgeInsets.all(20),
        color: yellow_color1,
        onPressed: () {
          SystemChannels.textInput.invokeMethod('Text Input hide');
          _submitData();
        },
        child: Text('按此建立群組',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: text_color2)),
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
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () { 
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
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
            //
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
                            onPressed: () {
                              logout();
                            },
                            child: Text('登出',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor)),
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('取消',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor)),
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
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
                          buildTransportation(),
                          buildFromTo(),
                          buildDetailInfo(),
                          buildPassengerType(),
                          buildTunnel(),
                          // buildWaitingBuffer(),
                          buildGoWithoutWaiting(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        bottomNavigationBar: buildBottomBtn(),
      ),
    );
  }
}
