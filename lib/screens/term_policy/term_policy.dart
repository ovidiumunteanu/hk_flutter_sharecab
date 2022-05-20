import 'package:flutter/material.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/utils/constant.dart';

class TermPolicy extends StatefulWidget {
  bool isTerm;
  TermPolicy({this.isTerm});
  @override
  _TermPolicyState createState() => _TermPolicyState();
}

class _TermPolicyState extends State<TermPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: yellow_color2,
          leadingWidth: 32,
          leading: Container(
            padding: EdgeInsets.only(left: 6),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.chevron_left,
                color: text_color1,
                size: 32,
              ),
            ),
          ),
          titleSpacing: 8,
          title: Row(children: [
            // Image.asset(
            //   'assets/images/logo_full_qq.png',
            //   width: 160,
            //   height: 22,
            // ),
            Text(
              widget.isTerm ? '免責聲明' : '私隱條例',
              style: TextStyle(
                  color: text_color1,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),
        body: Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "Hybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP version Hybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP versionHybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP versionHybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP versionHybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP versionHybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP versionHybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP versionHybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP versionHybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP versionHybrid AMP Pages: The Hybrid AMP pages allow the users to have coexisted AMP version",
                  style: TextStyle(
                      color: text_color1,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            )));
  }
}

class Helper {
  bool isExpanded;
  Image thumbnail;
  String heading;
  String description;

  Helper({this.heading, this.thumbnail, this.description, this.isExpanded});
}
