import 'package:flutter/material.dart';
import 'dart:io';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shareacab/utils/constant.dart';
import 'package:intl/intl.dart';

TextStyle optionTxt =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text_color1);
TextStyle hintTxt =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: text_color3);

class AuthInput extends StatelessWidget {
  final Function onChange;
  String label;
  String type;
  String initVal;
  bool enabled = true;
  AuthInput({this.label, this.initVal, this.enabled, this.type, this.onChange});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: text_color2),
          ),
          TextFormField(
            obscureText: type == 'pass',
            keyboardType:
                type == 'phone' ? TextInputType.phone : TextInputType.text,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: text_color1),
            decoration: InputDecoration(
                // hintText: label,
                ),
            validator: (val) => val.isEmpty ? '輸入有效數據' : null,
            onChanged: (val) {
              onChange(val);
            },
            initialValue: initVal == null ? '' : initVal,
            enabled: enabled,
          ),
          // Container(
          //   width: double.infinity,
          //   height: 1,
          //   decoration: BoxDecoration(
          //     color: grey_color1,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class DropdownInput extends StatelessWidget {
  final Function onChange;
  String label;
  TextStyle labelStyle;
  String hint;
  String curItem;
  List<String> items;
  DropdownInput(
      {this.label,
      this.labelStyle,
      this.hint,
      this.curItem,
      this.items,
      this.onChange});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: labelStyle != null
                ? labelStyle
                : TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: text_color2),
          ),
          SizedBox(
            height: 50,
            child: DropdownButtonFormField(
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: text_color1),
              decoration: InputDecoration(
                hintText: hint ?? 'Choose',
                hintStyle: TextStyle(fontSize: 14, color: grey_color1),
              ),
              value: curItem,
              onChanged: (newValue) {
                onChange(newValue);
              },
              items: items.map((temp) {
                return DropdownMenuItem(
                  value: temp,
                  child: Text(temp),
                );
              }).toList(),
            ),
          ),
          // Container(
          //   width: double.infinity,
          //   height: 1,
          //   decoration: BoxDecoration(
          //     color: grey_color1,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class RadioInput extends StatefulWidget {
  final Function onSelect;
  final List<String> items;
  String choice;
  String label;

  RadioInput(this.label, this.items, this.choice, this.onSelect);

  @override
  _RadioInputState createState() => _RadioInputState();
}

class _RadioInputState extends State<RadioInput> {
  String choice;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    choice = widget.choice;
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
      margin: EdgeInsets.only(top: 12),
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

  List<Widget> renderList() {
    var list = <Widget>[
      Text(
        widget.label,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: text_color1),
      ),
    ];

    for (var i = 0; i < widget.items.length; i++) {
      list.add(
          buildCheckboxRow(widget.items[i], widget.items[i] == choice, (val) {
        setState(() {
          choice = widget.items[i];
        });
        widget.onSelect(widget.items[i]);
      }));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(left: 20, right: 20, top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: grey_color2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: renderList(),
      ),
    );
  }
}

class DateTimeInput extends StatefulWidget {
  final Function onDateSelect;
  final Function onTimeSelect;

  DateTimeInput(this.onDateSelect, this.onTimeSelect);

  @override
  _DateTimeInputState createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  int newJoiningMember = 1;
  DateTime _selectedDepartureDate;
  TimeOfDay _selectedDepartureTime;

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
      widget.onDateSelect(pickedDate);
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
      widget.onTimeSelect(pickedTime);
      setState(() {
        _selectedDepartureTime = pickedTime;
        FocusScope.of(context).requestFocus(FocusNode());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    '出發日期',
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
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _startDatePicker(),
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
                                _selectedDepartureDate == null
                                    ? ''
                                    : '${DateFormat.yMd().format(_selectedDepartureDate)}',
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
                    '出發時間',
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
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _startTimePicker(),
                        child: Row(
                          children: [
                            Text(
                              _selectedDepartureTime == null
                                  ? ''
                                  : '${_selectedDepartureTime.toString().substring(10, 15)}',
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
}

class BottomCreateTripBtn extends StatefulWidget {
  final Function onPress;
  bool active;
  BottomCreateTripBtn(this.active, this.onPress);

  @override
  _BottomCreateTripBtnState createState() => _BottomCreateTripBtnState();
}

class _BottomCreateTripBtnState extends State<BottomCreateTripBtn> {
  bool keyboardOpened = false;
  int keyboardAddListener = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    keyboardAddListener =
        KeyboardVisibilityNotification().addNewListener(onShow: () {
      print("on show");
      setState(() {
        keyboardOpened = true;
      });
    }, onHide: () {
      print("on hide");
      setState(() {
        keyboardOpened = false;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    KeyboardVisibilityNotification().removeListener(keyboardAddListener);
  }

  @override
  Widget build(BuildContext context) {
    return widget.active
        ? Container(
            width: double.infinity,
            margin: EdgeInsets.only(
                bottom: keyboardOpened ? 0 : (Platform.isIOS ? 80 : 55)),
            child: FlatButton(
              height: 85,
              color: yellow_color1,
              onPressed: () {
                FocusScope.of(context).unfocus();
                widget.onPress();
              },
              child: Text('按此建立群組',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: text_color2)),
            ))
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                    bottom: keyboardOpened ? 0 : (Platform.isIOS ? 80 : 55)),
                height: 70,
                color: grey_color6,
                child: Center(
                  child: Text('您目前已經有群組了。',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: text_color2)),
                )));
  }
}
