import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shareacab/models/requestdetails.dart';
import 'package:shareacab/models/user.dart';
import 'package:shareacab/screens/chatscreen/chat_database/chatservices.dart';

class DatabaseService {
  final String uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseService({this.uid});

  //collection reference
  final CollectionReference userDetails =
      Firestore.instance.collection('userdetails');
  final CollectionReference groupdetails =
      Firestore.instance.collection('group');
  final CollectionReference requests =
      Firestore.instance.collection('requests');

  // Enter user data (W=1, R=0)
  Future enterUserData(
      {String name, String mobileNumber, String hostel, String sex}) async {
    return await userDetails.document(uid).setData({
      'name': name,
      'mobileNumber': mobileNumber,
      'hostel': hostel,
      'sex': sex,
      'totalRides': 0,
      'cancelledRides': 0,
      'actualRating': 0,
      'numberOfRatings': 0,
    });
  }

  // Update user data (W=1/2,R=1)
  Future updateUserData(
      {String name, String mobileNumber, String hostel, String sex}) async {
    var currentGrp;
    var user = await _auth.currentUser();
    await Firestore.instance
        .collection('userdetails')
        .document(user.uid)
        .get()
        .then((value) {
      currentGrp = value.data['currentGroup'];
    });
    await userDetails.document(uid).updateData({
      'name': name,
      'mobileNumber': mobileNumber,
      'hostel': hostel,
      'sex': sex,
    });
    if (currentGrp != null) {
      await groupdetails
          .document(currentGrp)
          .collection('users')
          .document(user.uid)
          .setData({
        'name': name,
        'mobilenum': mobileNumber,
        'hostel': hostel,
        'sex': sex,
      }, merge: true);
    }
  }

  // user list from snapshot
  List<Userdetails> _UserListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Userdetails(
        uid: doc.documentID,
        name: doc.data['name'] ?? '',
        mobilenum: doc.data['mobileNumber'] ?? '',
        hostel: doc.data['hostel'] ?? '',
        sex: doc.data['sex'] ?? '',
        totalrides: doc.data['totalRides'] ?? 0,
        cancelledrides: doc.data['cancelledRides'] ?? 0,
        actualrating: doc.data['actualRating'] ?? 0,
        numberofratings: doc.data['numberOfRatings'] ?? 0,
      );
    }).toList();
  }

  // get users stream
  Stream<List<Userdetails>> get users {
    return userDetails.snapshots().map(_UserListFromSnapshot);
  }

  // get user doc
  Stream<DocumentSnapshot> get userData {
    return userDetails.document(uid).snapshots();
  }

  // add group details (W = 4, R = 0)
  Future<void> createTrip(RequestDetails requestDetails) async {
    var user = await _auth.currentUser();

    // CODE FOR CONVERTING DATE TIME TO TIMESTAMP
    var temp = requestDetails.departureTime;
    var departure_time = DateTime(
        requestDetails.departureDate.year,
        requestDetails.departureDate.month,
        requestDetails.departureDate.day,
        temp.hour,
        temp.minute);

    final docRef = await groupdetails.add({
      'owner': user.uid.toString(),
      'users': FieldValue.arrayUnion([user.uid]),
      'transportation': requestDetails.transportation,
      'departure': requestDetails.departure,
      'destination': requestDetails.destination,
      'departure_location': requestDetails.departure_location,
      'destination_location': requestDetails.destination_location,
      'departure_time': departure_time,
      'maxMembers': requestDetails.maxMembers,
      'sex': requestDetails.sex,
      'tunnel': requestDetails.tunnel,
      'waiting_time': requestDetails.waiting_time,
      'wait_all_member': requestDetails.wait_all_member, 
      'end': false,
      'created': Timestamp.now(), 
    });

    //adding user to group chat
    await ChatService().createChatRoom(docRef.documentID, user.uid.toString(),
        requestDetails.destination.toString());

    await userDetails.document(user.uid).updateData({
      'currentGroup': docRef.documentID,
    });

    var request = groupdetails.document(docRef.documentID).collection('users');
    await Firestore.instance
        .collection('userdetails')
        .document(user.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        await request.document(user.uid).setData({
          'uid': user.uid,
          'name': value.data['name'],
          'hostel': value.data['hostel'],
          'sex': value.data['sex'],
          'mobilenum': value.data['mobileNumber'],
          'totalrides': value.data['totalRides'],
          'cancelledrides': value.data['cancelledRides'],
          'actualrating': value.data['actualRating'],
          'numberofratings': value.data['numberOfRatings']
        });
      }
    });
  }

  Future<void> updateGroup(RequestDetails requestDetails) async {
    // CODE FOR CONVERTING DATE TIME TO TIMESTAMP
    var temp = requestDetails.departureTime;
    var departure_time = DateTime(
        requestDetails.departureDate.year,
        requestDetails.departureDate.month,
        requestDetails.departureDate.day,
        temp.hour,
        temp.minute);

    await groupdetails.document(requestDetails.id).setData({ 
      'transportation': requestDetails.transportation,
      'departure': requestDetails.departure,
      'destination': requestDetails.destination,
      'departure_location': requestDetails.departure_location,
      'destination_location': requestDetails.destination_location,
      'departure_time': departure_time,
      'maxMembers': requestDetails.maxMembers,
      'sex': requestDetails.sex,
      'tunnel': requestDetails.tunnel,
      'waiting_time': requestDetails.waiting_time,
      'wait_all_member': requestDetails.wait_all_member, 
    }, merge: true);
  }

  // exit a group (W=4/5, R =3/4)
  Future<void> exitGroup() async {
    var user = await _auth.currentUser();
    var currentGrp;
    int presentNum;
    var totalRides;
    var cancelledRides;
    var owner;
    await Firestore.instance
        .collection('userdetails')
        .document(user.uid)
        .get()
        .then((value) {
      currentGrp = value.data['currentGroup'];
      totalRides = value.data['totalRides'];
      cancelledRides = value.data['cancelledRides'];
    });
    await groupdetails.document(currentGrp).get().then((value) {
      presentNum = value.data['users'].length;
      owner = value.data['owner'];
    });

    await userDetails.document(user.uid).updateData({
      'currentGroup': null,
    });

    if (presentNum > 1) {
      await groupdetails.document(currentGrp).updateData({
        'users': FieldValue.arrayRemove([user.uid]),
      });
      await groupdetails
          .document(currentGrp)
          .collection('users')
          .document(user.uid)
          .delete();
      if (owner == user.uid) {
        var newowner;
        await groupdetails.document(currentGrp).get().then((value) {
          newowner = value.data['users'][0];
        });
        await groupdetails.document(currentGrp).updateData({
          'owner': newowner,
        });
      }
      //deleting user from chat group
      await ChatService().exitChatRoom(currentGrp);
    } else {
      await groupdetails.document(currentGrp).delete();
    }
  }

  // join a group from dashboard (W=4,R=2)
  Future<void> joinGroup(String listuid) async {
    var user = await _auth.currentUser();

    await userDetails.document(user.uid).updateData({
      'currentGroup': listuid,
    });
    await groupdetails.document(listuid).updateData({
      'users': FieldValue.arrayUnion([user.uid.toString()]),
    });

    var request = groupdetails.document(listuid).collection('users');
    await Firestore.instance
        .collection('userdetails')
        .document(user.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        await request.document(user.uid).setData({
          'uid': user.uid,
          'name': value.data['name'],
          'hostel': value.data['hostel'],
          'sex': value.data['sex'],
          'mobilenum': value.data['mobileNumber'],
          'totalrides': value.data['totalRides'],
          'actualrating': value.data['actualRating'],
          'cancelledrides': value.data['cancelledRides'],
          'numberofratings': value.data['numberOfRatings'],
        });
      }
    });
    //calling chat service to add the user to chatgroup also
    await ChatService().joinGroup(listuid);
  }

  Future<void> setArrived(String listuid) async {
    var user = await _auth.currentUser();

    var request = groupdetails.document(listuid).collection('users');
    await request.document(user.uid).setData({'isArrived': true}, merge: true);
  }

  // set device token (W=1,R=0)
  Future<void> setToken(String token) async {
    final user = await _auth.currentUser();
    await userDetails.document(user.uid).updateData({'device_token': token});
  }

  // Function for kicking a user (ADMIN ONLY) (W=4,R=1)
  Future<void> kickUser(String currentGrp, String uid) async {
    await groupdetails
        .document(currentGrp)
        .collection('users')
        .document(uid)
        .delete();

    await userDetails.document(uid).updateData({
      'currentGroup': null,
    });
    await groupdetails.document(currentGrp).updateData({
      'users': FieldValue.arrayRemove([uid]),
    });
    await ChatService().kickedChatRoom(currentGrp, uid);
  }
}
