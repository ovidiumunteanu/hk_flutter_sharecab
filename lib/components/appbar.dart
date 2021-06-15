import 'package:flutter/material.dart';
import 'package:shareacab/screens/help.dart';
import 'package:shareacab/screens/profile/userprofile.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/utils/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

AppBar CustomAppBar(BuildContext context, AuthService _auth) {
  return AppBar(
    backgroundColor: yellow_color2,
    title: Row(
      children: [
        Image.asset(
          'assets/images/logo_full_qq.png',
          width: 180,
          height: 26,
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
      IconButton(
        icon: Icon(
          Icons.help,
          color: text_color1,
          size: 28,
        ),
        tooltip: 'Help',
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Help()));
        },
      ),
      IconButton(
          icon: Icon(
            FontAwesomeIcons.solidUserCircle,
            color: text_color1,
            size: 24,
          ),
          tooltip: '帳戶',
          onPressed: () {
            return Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return MyProfile(_auth);
            }));
          }),
    ],
  );
}
