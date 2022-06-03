import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/models/user.dart';
import 'package:shareacab/services/database.dart';
import 'package:shareacab/utils/constant.dart';

class TextSetting extends StatefulWidget {
  final String type;
  TextSetting(this.type);
  @override
  _TextSettingState createState() => _TextSettingState();
}

class _TextSettingState extends State<TextSetting> {
  var isLoading = false;
  final _textEditController = TextEditingController();
  String text = '';

  @override
  void initState() {
    super.initState();
  }

  void onSave() {
    Firestore.instance
        .collection('settings')
        .document(widget.type)
        .setData({'text': _textEditController.text}, merge: true);
    Navigator.pop(context);
  }

  String getTitle() {
    if (widget.type == 'news') {
      return '最新消息';
    } else if (widget.type == 'terms') {
      return '免責聲明';
    } else if (widget.type == 'policy') {
      return '私隱條例';
    } else if (widget.type == 'faq') {
      return 'F&Q問答';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
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
          elevation: 0,
          titleSpacing: 8,
          title: Row(children: [
            // Image.asset(
            //   'assets/images/logo_full_qq.png',
            //   width: 160,
            //   height: 22,
            // ),
            Text(
              getTitle(),
              style: TextStyle(
                  color: text_color1,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),
        body: StreamBuilder(
            stream: Firestore.instance.collection('settings').snapshots(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                Center(child: CircularProgressIndicator());
              }

              var textdata = '';
              if (snapshot.data != null) {
                for (var i = 0; i < snapshot.data.documents.length; i++) {
                  final doc = snapshot.data.documents[i];
                  if (widget.type == 'news' && doc.documentID == 'news') {
                    textdata = doc.data['text'] ?? '';
                  } else if (widget.type == 'terms' &&
                      doc.documentID == 'terms') {
                    textdata = doc.data['text'] ?? '';
                  } else if (widget.type == 'policy' &&
                      doc.documentID == 'policy') {
                    textdata = doc.data['text'] ?? '';
                  } else if (widget.type == 'faq' && doc.documentID == 'faq') {
                    textdata = doc.data['text'] ?? '';
                  }
                }
                _textEditController.text = textdata;
              }
              return Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            color: Color(0xFFf7f7f7),
                            child: TextFormField(
                                minLines: 15,
                                maxLines: 40,
                                controller: _textEditController,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: text_color1),
                                decoration: InputDecoration(
                                    hintText: '請輸入內容',
                                    hintStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFBBBBBB)),
                                    border: InputBorder.none),
                                 ),
                                 
                          )),
                    ),
                    Container(
                      width: double.infinity,
                      child: FlatButton(
                        color: yellow_color1,
                        onPressed: onSave,
                        height: 60,
                        child: Text(
                          '確認', // You are in a group and viewing a private group
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: text_color2),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }));
  }
}
