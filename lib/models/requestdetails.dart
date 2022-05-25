import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
     
class RequestDetails {
  @required
  final String id;
  @required
  final String name;
  @required
  final String transportation;
  @required
  final String departure;
  @required
  final String departure_sub;
  @required
  final String destination;
  @required
  final String destination_sub;
  @required
  final String departure_location;
  @required
  final String destination_location;
  @required
  final DateTime departureDate;
  @required
  final TimeOfDay departureTime;
  @required
  final int maxMembers;
  @required
  final int curMembers;
  @required
  final String sex;
  @required
  final String tunnel;
  @required
  final String covid;
  @required
  final String reference_number;
  @required
  final int waiting_time;
  @required
  final bool wait_all_member; 

  RequestDetails({
    this.id, 
    this.name, 
    this.transportation,
    this.departure,
    this.departure_sub,
    this.destination, 
    this.destination_sub,
    this.departure_location,
    this.destination_location, 
    this.departureDate, 
    this.departureTime,
    this.maxMembers,
    this.curMembers,
    this.sex,
    this.tunnel, 
    this.covid,
    this.reference_number,
    this.waiting_time,
    this.wait_all_member, 
  });
}
