import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:intl/intl.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/services/trips.dart';

class CreateTrip extends StatefulWidget {
  static const routeName = '/createTrip';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  _CreateTripState createState() => _CreateTripState();
}

class _CreateTripState extends State<CreateTrip> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _finalDestinationController = TextEditingController();
  final RequestService _request = RequestService();

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

  void _addNewRequest() async {
    final newRq = RequestDetails(
        id: DateTime.now().toString(),
        name: 'Name',
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
      _formKey.currentState.save();
      _addNewRequest();
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

  Widget buildContainer(String point, DateTime date, TimeOfDay time,
      Function DatePicker, Function TimePicker) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(date == null
              ? '$point Date'
              : '${DateFormat.yMd().format(date)}'),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () => DatePicker(),
          ),
          Text(time == null
              ? '$point Time'
              : '${time.toString().substring(10, 15)}'),
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

  // SORTING THE LIST IN ALPHABETICAL FOR DESTINATIONS
  @override
  void initState() {
    destinations.sort();
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Create Trip'),
        ),
        body: Builder(builder: (BuildContext context) {
          return Container(
            //padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
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
                          SystemChannels.textInput
                              .invokeMethod('Text Input hide');
                          _submitData();
                        },
                        color: Theme.of(context).accentColor,
                        child:
                            Text('Create Trip', style: TextStyle(fontSize: 18)),
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
