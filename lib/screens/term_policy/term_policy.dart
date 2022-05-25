import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shareacab/utils/constant.dart';

class TermsPolicy extends StatefulWidget {
  final String type;
  TermsPolicy(this.type);
  @override
  _TermsPolicyState createState() => _TermsPolicyState();
}

class _TermsPolicyState extends State<TermsPolicy> {
  var isLoading = false;
  final _textEditController = TextEditingController();
  String text = '';

  @override
  void initState() {
    super.initState();
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
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          textdata,
                          style: TextStyle(fontSize: 15, color: text_color1),
                        )),
                  ],
                ),
              );
            }));
  }
}
