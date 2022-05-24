import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shareacab/screens/admin/admindashboard.dart';
import 'package:shareacab/screens/help.dart';
import 'package:shareacab/screens/profile/userprofile.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/services/database.dart';
import 'package:shareacab/shared/guest.dart';
import 'package:shareacab/utils/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shareacab/utils/global.dart';

AppBar CustomAppBar(
    BuildContext context, AuthService _auth, FirebaseUser currentuser) {
  return AppBar(
    backgroundColor: yellow_color2,
    titleSpacing: 6,
    title: Row(
      children: [
        Image.asset(
          'assets/images/logo_full_qq.png',
          width: 160,
          height: 22,
        ),
        // SizedBox(
        //   width: 5,
        // ),
        // Text(
        //   'AA制車資',
        //   style: TextStyle(
        //       fontSize: 20, fontWeight: FontWeight.w600, color: text_color1),
        // ),
      ],
    ),
    actions: <Widget>[
      Container(
        width: 28,
        height: 28,
        child: IconButton(
          padding: EdgeInsets.zero,
          focusColor: Colors.amber,
          icon: Icon(
            Icons.help,
            color: text_color1,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Help()));
          },
        ),
      ),
      Container(
        width: 28,
        height: 28,
        margin: EdgeInsets.only(left: 10, right: 8),
        child: IconButton(
            padding: EdgeInsets.only(bottom: 2),
            icon: Icon(
              FontAwesomeIcons.solidUserCircle,
              color: text_color1,
              size: 24,
            ),
            onPressed: () {
              if (currentuser == null) {
                GUEST_SERVICE.showGuestModal(context);
              } else {
                return Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return MyProfile(_auth);
                }));
              }
            }),
      ),
      StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService(uid: currentuser == null ? '' : currentuser.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) { 
            return Container(
              width: 28,
              height: 28,
              margin: EdgeInsets.only(right: 12),
              child: IconButton(
                  padding: EdgeInsets.only(bottom: 1),
                  icon: Icon(
                    Icons.settings,
                    color: text_color1,
                    size: 26,
                  ),
                  onPressed: () {
                    if (currentuser == null) {
                      GUEST_SERVICE.showGuestModal(context);
                    } else {
                      return Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AdminDashboard();
                      }));
                    }
                  }));
          }
          else {
            return Container();
          }
        })
    ],
  );
}
