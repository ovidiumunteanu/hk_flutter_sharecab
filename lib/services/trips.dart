import 'package:flutter/material.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:shareacab/services/database.dart';

class RequestService {
  Future<void> createTrip(RequestDetails requestDetails) async {
    await DatabaseService().createTrip(requestDetails);
  }

  Future<void> exitGroup() async {
    await DatabaseService().exitGroup();
  }


  Future<void> removeGroup(group_id) async {
    await DatabaseService().removeGroup(group_id);
  }

  Future<void> joinGroup(String listuid, int numUsers) async {
    await DatabaseService().joinGroup(listuid, numUsers);
  }

  Future<void> setDeviceToken(String token) async {
    await DatabaseService().setToken(token);
  }

  Future<void> kickUser(String currentGrp, String uid) async {
    await DatabaseService().kickUser(currentGrp, uid);
  }
}
