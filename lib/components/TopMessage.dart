import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shareacab/utils/constant.dart';

class TopMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('settings').snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          var textdata = '';
          if (snapshot.data != null) {
            for (var i = 0; i < snapshot.data.documents.length; i++) {
              final doc = snapshot.data.documents[i];
              if (doc.documentID == 'news') {
                textdata = doc.data['text'] ?? '';
              }
            }
          }
          if (textdata == '') {
            return Container();
          }
          return Container(
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                color: yellow_color1,
              ),
              child: Center(
                child: Text(
                  textdata,
                  style: TextStyle(
                    fontSize: 14,
                    color: text_color4,
                  ),
                ),
              ));
        });
  }
}
