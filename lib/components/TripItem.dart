import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shareacab/utils/constant.dart';

class TripItem extends StatelessWidget {
  final Function onPress;
  String departure;
  String destination;
  String departure_loc;
  String destination_loc;
  int maxMember = 0;
  int joinedMember = 0;
  DateTime departure_time;
  TripItem(
      {this.departure,
      this.destination,
      this.departure_loc,
      this.destination_loc,
      this.maxMember,
      this.joinedMember,
      this.departure_time,
      this.onPress});
  String today_str = DateFormat('yyyy.MM.dd').format(DateTime.now());

  Widget buildRowInfo(String key, String value) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: Text(
            key,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: text_color3),
            textAlign: TextAlign.start,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 12),
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: text_color1),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, left: 25, right: 25),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                departure,
                style: TextStyle(
                    fontSize:  22,
                    fontWeight: FontWeight.bold,
                    color: red_color2),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5, left: 12, right: 12),
                child: Text(
                  '往',
                  style: TextStyle(color: text_color3, fontSize: 12),
                ),
              ),
              Text(
                destination,
                style: TextStyle(
                    fontSize:  22,
                    fontWeight: FontWeight.bold,
                    color: grey_color4),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(bottom: 5, left: 10, right: 10),
                child: Text(
                  '出發於',
                  style: TextStyle(color: text_color3, fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Column(
                  children: [
                    Text(
                      '${DateFormat('kk:mm a').format(departure_time)}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                    Text(
                      '${DateFormat('yyyy.MM.dd').format(departure_time) == today_str ? '今天' : DateFormat('yyyy.MM.dd').format(departure_time)}',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    buildRowInfo('集合點  ', departure_loc),
                    buildRowInfo('出發到  ', destination_loc),
                  ],
                ),
              ),
              Text(
                '$joinedMember/$MAX_GROUP_MEMBERS',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              )
            ],
          ),
        ],
      )),
    );
  }
}
