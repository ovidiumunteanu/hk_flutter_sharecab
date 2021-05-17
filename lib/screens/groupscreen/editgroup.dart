import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/services/database.dart';
import 'package:shareacab/models/requestdetails.dart';

class EditGroup extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final String groupUID;
  EditGroup({Key key, this.groupUID}) : super(key: key);

  @override
  _EditGroupState createState() => _EditGroupState(groupUID);
}

class _EditGroupState extends State<EditGroup> {
 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseService _databaseService = DatabaseService();
  String groupUID;
  _EditGroupState(this.groupUID);

  final _dest_loc_Controller = TextEditingController();
  final _depart_loc_Controller = TextEditingController();

  List<String> destinations = [
    'New Delhi Railway Station',
    'Indira Gandhi International Airport',
    'Anand Vihar ISBT',
    'Hazrat Nizamuddin Railway Station'
  ];
  List<int> maxpoolers = [1, 2, 3, 4, 5, 6, 7];
  String _destination;
  String _destination_location;
  String _departure_location;
  DateTime _selectedDepartureDate;
  TimeOfDay _selectedDepartureTime;
  String _rule = '4 Person Taxi';
  String _sex = 'Any';
  int _maxMembers = 1;
  int _waiting_time = 0;
  bool _wait_all_member = false;
  bool _require_permission = false;

  void _updateGroup() async {
    try {
        final newRq = RequestDetails(
        id: groupUID,
        destination: _destination,
        destination_location: _destination_location,
        departure_location: _departure_location,
        departureDate: _selectedDepartureDate,
        departureTime: _selectedDepartureTime,
        rule: _rule,
        sex: _sex,
        waiting_time: _waiting_time,
        wait_all_member: _wait_all_member,
        require_permission: _require_permission,
        maxPoolers: _maxMembers);

      await _databaseService.updateGroup(newRq);
    } catch (e) {
      print(e.toString());
    }
  }

  void _submitData() {

    if (_destination == null ||
        _destination_location == null ||
        _departure_location == null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Theme.of(context).primaryColor,
        content: Text('One or more fields is missing',
            style: TextStyle(color: Theme.of(context).accentColor)),
      ));
      return; //return stops function execution and thus nothing is called or returned
    } else if (_selectedDepartureDate == null ||
        _selectedDepartureTime == null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        backgroundColor: Theme.of(context).primaryColor,
        content: Text('Date or Time is missing',
            style: TextStyle(color: Theme.of(context).accentColor)),
      ));
      return;
    } else {
      _updateGroup();
      Navigator.of(context).pop();
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
             fit: FlexFit.tight,
             flex: 1,
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

  Widget buildContainer(String point, DateTime date, TimeOfDay time, Function DatePicker, Function TimePicker) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(date == null ? '$point Date' : '${DateFormat.yMd().format(date)}'),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () => DatePicker(),
          ),
          Text(time == null ? '$point Time' : '${time.toString().substring(10, 15)}'),
          IconButton(
            icon: Icon(
              Icons.schedule,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () => TimePicker(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    Firestore.instance.collection('group').document(groupUID).get().then((value) {
      setState(() {
      _destination = value.data['destination'];
      _destination_location = value.data['destination_location'];
      _departure_location = value.data['departure_location'];
      _rule = value.data['rule'];
      _sex = value.data['sex'];
      _selectedDepartureDate =  value.data['departure_time'].toDate();
      _selectedDepartureTime = TimeOfDay(hour: _selectedDepartureDate.hour, minute: _selectedDepartureDate.minute);
      _maxMembers = value.data['maxPoolers'];
      _require_permission = value.data['require_permission'];
      _waiting_time = value.data['waiting_time'];
      _wait_all_member = value.data['wait_all_member'];
      });
  _dest_loc_Controller.text = value.data['destination_location'];
  _depart_loc_Controller.text = value.data['departure_location'];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Edit Group'),
          ),
          body: Builder(builder: (BuildContext context) {
          return Container(
            //padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  children: <Widget>[
                    buildLabel('Where are we going?'),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            top: 20,
                            left: 40,
                          ),
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: DropdownButtonFormField<String>(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                            ),
                            items:
                                destinations.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(
                                  dropDownStringItem,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            value: _destination,
                            onChanged: (val) {
                              setState(() {
                                _destination = val;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please Enter Destination';
                              }
                              return null;
                            },
                            hint: Text('Destination'),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 20,
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Destination Location',
                        ),
                        validator: (val) => val.length == 0
                            ? 'Enter a destination location.'
                            : null,
                        controller: _dest_loc_Controller,
                        onChanged: (val) {
                          setState(() => _destination_location = val);
                        },
                      ),
                    ),
                    buildLabel('Where are we meeting?'),
                    Container(
                      margin: EdgeInsets.only(
                        top: 20,
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Departure Location',
                        ),
                        validator: (val) => val.length == 0
                            ? 'Enter a departure location.'
                            : null,
                        onChanged: (val) {
                          setState(() => _departure_location = val);
                        },
                        controller: _depart_loc_Controller,
                      ),
                    ),
                    buildContainer(
                        'Departure',
                        _selectedDepartureDate,
                        _selectedDepartureTime,
                        _startDatePicker,
                        _startTimePicker),
                    buildLabel('Setup your rules'),
                    Container(
                      margin: EdgeInsets.only(
                        top: 20,
                        left: 20,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          children: ['4 Person Taxi', '5 Person Taxi', 'Uber']
                              .map((String rule_item) {
                            return Container(
                              margin: EdgeInsets.only(
                                top: 6,
                                left: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Checkbox(
                                      checkColor:
                                          getVisibleColorOnAccentColor(context),
                                      activeColor:
                                          Theme.of(context).accentColor,
                                      value: _rule == rule_item,
                                      onChanged: (bool value) {
                                        setState(() {
                                          _rule = rule_item;
                                        });
                                      }),
                                  Text(rule_item,
                                      style: TextStyle(
                                        color: getVisibleTextColorOnScaffold(
                                            context),
                                      )),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 20,
                        left: 20,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          children: ['All Male', 'All Female', 'Any']
                              .map((String sex_item) {
                            return Container(
                              margin: EdgeInsets.only(
                                top: 6,
                                left: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Checkbox(
                                      checkColor:
                                          getVisibleColorOnAccentColor(context),
                                      activeColor:
                                          Theme.of(context).accentColor,
                                      value: _sex == sex_item,
                                      onChanged: (bool value) {
                                        setState(() {
                                          _sex = sex_item;
                                        });
                                      }),
                                  Text(sex_item,
                                      style: TextStyle(
                                        color: getVisibleTextColorOnScaffold(
                                            context),
                                      )),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, left: 40.0),
                          child: Text('No. of members: ',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: getVisibleTextColorOnScaffold(context),
                              )),
                        ),
                        Container(
                          width: 45,
                          margin: EdgeInsets.only(top: 30.0, left: 20),
                          child: DropdownButtonFormField<int>(
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                            ),
                            items: maxpoolers.map((int dropDownIntItem) {
                              return DropdownMenuItem<int>(
                                value: dropDownIntItem,
                                child: Text(
                                  dropDownIntItem.toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            value: _maxMembers,
                            onChanged: (val) {
                              setState(() {
                                _maxMembers = val;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Empty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    buildLabel('Waiting time limited'),
                    Container(
                      margin: EdgeInsets.only(
                        top: 20,
                        left: 20,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(children: 
                        [0, 5, 10, 15].map((int time_value) {
                          return
                            Container(
                              margin: EdgeInsets.only(
                                top: 6,
                                left: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Checkbox(
                                      checkColor:
                                          getVisibleColorOnAccentColor(context),
                                      activeColor:
                                          Theme.of(context).accentColor,
                                      value: time_value == _waiting_time,
                                      onChanged: (bool value) {
                                        setState(() {
                                          _waiting_time = time_value;
                                        });
                                      }),
                                  Text('$time_value minutes',
                                      style: TextStyle(
                                        color: getVisibleTextColorOnScaffold(
                                            context),
                                      )),
                                ],
                              ),
                            );
                        }).toList()
                        ),
                      ),
                    ),
                    buildLabel(
                        'Required wait for all member arrive before going?'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            top: 20,
                            left: 30,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                  checkColor:
                                      getVisibleColorOnAccentColor(context),
                                  activeColor: Theme.of(context).accentColor,
                                  value: _wait_all_member == true,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _wait_all_member = value == true;
                                    });
                                  }),
                              Text('Yes',
                                  style: TextStyle(
                                    color:
                                        getVisibleTextColorOnScaffold(context),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 20,
                            left: 30,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                  checkColor:
                                      getVisibleColorOnAccentColor(context),
                                  activeColor: Theme.of(context).accentColor,
                                  value: _wait_all_member == false,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _wait_all_member = value == false;
                                    });
                                  }),
                              Text('No',
                                  style: TextStyle(
                                    color:
                                        getVisibleTextColorOnScaffold(context),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 20,
                        left: 30,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Checkbox(
                              checkColor: getVisibleColorOnAccentColor(context),
                              activeColor: Theme.of(context).accentColor,
                              value: _require_permission,
                              onChanged: (bool value) {
                                setState(() {
                                  _require_permission = value;
                                });
                              }),
                          Text('Require Permission To Join Trip',
                              style: TextStyle(
                                color: getVisibleTextColorOnScaffold(context),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 150,
                      margin: EdgeInsets.only(
                        top: 40,
                        bottom: 30,
                        right: 20,
                      ),
                      child: RaisedButton(
                        textColor: getVisibleColorOnAccentColor(context),
                        onPressed: () {
                          _submitData();
                        },
                        color: Theme.of(context).accentColor,
                        child:
                            Text('Edit Group', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
          
          ),
    
    
    );
  }
}
