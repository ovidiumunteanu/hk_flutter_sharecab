import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shareacab/utils/constant.dart';

class TripItem extends StatelessWidget {
  final Function onPress;
  String departure;
  String destination;
  String departure_loc;
  String destination_loc;
  int maxMember;
  int joinedMember;
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
                fontSize: 12, fontWeight: FontWeight.w400, color: text_color3),
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
                  fontSize: 12,
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
            children: [
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          departure,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: red_color2),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(bottom: 5, left: 12, right: 12),
                          child: Text(
                            '往',
                            style: TextStyle(color: text_color3),
                          ),
                        ),
                        Text(
                          destination,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: grey_color4),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(bottom: 5, left: 12, right: 12),
                          child: Text(
                            '於',
                            style: TextStyle(color: text_color3),
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
                                '${DateFormat('yyyy.MM.dd').format(departure_time)}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    buildRowInfo('集合點  ', departure_loc),
                    buildRowInfo('出發到  ', destination_loc),
                  ],
                ),
              ),
              Text(
                '$joinedMember/$maxMember',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              )
            ],
          ),
        ],
      )),
    );
  }
}
