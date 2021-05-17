import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RequestDetails {
   @required
  final String id;
  @required
  final String name;
  @required
  final String destination;
  @required
  final String destination_location;
  @required
  final String departure_location;
  @required
  final DateTime departureDate;
  @required
  final TimeOfDay departureTime;
  @required
  final String rule;
  @required
  final String sex;
  @required
  final int waiting_time;
  @required
  final bool wait_all_member;
  @required
  final bool require_permission;
  @required
  final int maxPoolers;

  RequestDetails({
    this.id, 
    this.name, 
    this.destination, 
    this.destination_location, 
    this.departure_location,
    this.departureDate, 
    this.departureTime,
    this.rule,
    this.sex,
    this.waiting_time,
    this.wait_all_member,
    this.require_permission,
    this.maxPoolers
  });
}
