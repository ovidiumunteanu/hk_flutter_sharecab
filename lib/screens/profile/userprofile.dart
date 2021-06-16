import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/screens/rootscreen.dart';
import 'package:shareacab/shared/loading.dart';
import 'package:shareacab/utils/constant.dart';
import '../../main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/components/buttons.dart';
import 'package:shareacab/services/database.dart';
import 'package:shareacab/utils/constant.dart';

class MyProfile extends StatefulWidget {
  final AuthService _auth;
  MyProfile(this._auth);
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile>
    with AutomaticKeepAliveClientMixin<MyProfile> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  FirebaseUser currentUser;
  String phone = '';
  String email = '';
  String name = '';
  String sex = '男性';

  bool genderChanged = false;

  @override
  void initState() {
    super.initState();
  }
 
  final List<String> _sex = [ '男性', '女性',];

  void onUpdate(DocumentSnapshot curData) async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
        message: '更新中...',
        backgroundColor: Theme.of(context).backgroundColor,
        messageTextStyle: TextStyle(
          color: getVisibleTextColorOnScaffold(context),
        ),
      );
      await pr.show();
      await Future.delayed(Duration(seconds: 1));
      try {
        final UID = await widget._auth.getCurrentUID();

        var newGender = (curData.data['sex'] == null || curData.data['sex'] == '') ? sex : curData.data['sex'];
        await widget._auth.updateUser(
            userid: UID,
            email: email == '' ? curData.data['email'] : email, 
            phone: curData.data['mobileNumber'],
            name: name == '' ? curData.data['name'] : name,
            sex: genderChanged ? sex : newGender );
        Navigator.pop(context);
        await pr.hide();
      } catch (e) {
        print(e.toString());
        await pr.hide();
        scaffoldKey.currentState.hideCurrentSnackBar();
        scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: yellow_color2,
          duration: Duration(seconds: 2),
          content: Text(
            e.toString(),
            style: TextStyle(color: text_color1),
          ),
        ));
      }
    }
  }

  void logout() async {
    ProgressDialog pr;
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: '處理中..',
      backgroundColor: Theme.of(context).backgroundColor,
      messageTextStyle: TextStyle(color: Theme.of(context).accentColor),
    );
    await pr.show();
    await Future.delayed(Duration(seconds: 1));
    try {
      await widget._auth.signOut();
      await pr.hide();
      Navigator.of(context).pop();
    } catch (err) {
      await pr.hide();
      String errStr = err.message ?? err.toString();
      final snackBar =
          SnackBar(content: Text(errStr), duration: Duration(seconds: 3));
      scaffoldKey.currentState.showSnackBar(snackBar);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService(uid: user == null ? '' : user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) { 
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: yellow_color2,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.chevron_left,
                      color: text_color1,
                      size: 36,
                    ),
                  ),
                  title: Text(
                    '帳戶',
                    style: TextStyle(fontSize: 22, color: text_color1),
                  ),
                  elevation: 0,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.signOutAlt,
                        color: text_color1,
                      ),
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: Text('登出'),
                                content: Text('您確定要退出嗎？'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      logout();
                                    },
                                    child: Text('登出',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor)),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('取消',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor)),
                                  ),
                                ],
                              );
                            });
                      },
                    )
                  ],
                ),
                body: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          AuthInput(
                              label: '名稱',
                              type: 'text',
                              initVal: snapshot.data['name'],
                              onChange: (val) {
                                setState(() => name = val);
                              }),
                          SizedBox(height: 20.0),
                          AuthInput(
                              label: '電子郵件',
                              type: 'email',
                              initVal: snapshot.data['email'],
                              onChange: (val) {
                                setState(() => email = val);
                              }),
                          SizedBox(height: 20.0),
                          AuthInput(
                              label: '電話號碼',
                              type: 'phone',
                              enabled: false,
                              initVal: snapshot.data['mobileNumber'],
                              onChange: (val) {
                                setState(() => phone = val);
                              }),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 110,
                                child: DropdownInput(
                                  label: '性別',
                                  hint: '請選擇',
                                  curItem: (snapshot.data['sex'] == null || snapshot.data['sex'] == '') ? sex : snapshot.data['sex'],
                                  items: _sex,
                                  onChange: (newValue) {
                                    setState(() {
                                      sex = newValue;
                                      genderChanged = true;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 60.0),
                          MainBtn(
                            label: '更新',
                            height: 64,
                            onPress: () {
                              onUpdate(snapshot.data);
                            },
                          ),
                          SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Loading();
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}
