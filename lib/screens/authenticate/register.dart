import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/services/database.dart';
import 'package:shareacab/shared/loading.dart';
import 'package:shareacab/screens/authenticate/phoneverify.dart';
import 'package:flutter/cupertino.dart';
import 'package:shareacab/utils/constant.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/components/buttons.dart';

import '../wrapper.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String phone = '';
  String email = '';
  String name = '';
  String sex = '男性';
  String verify = '';

  final List<String> _sex = [ '男性', '女性',];

  bool isPolicyChecked = false;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> isRegistered() async {
    var data = await _db.getUserbyPhone('+852' + phone);
    if (data == null) {
      return false;
    }
    return data.documents.length > 0;
  }

  Future<String> verifyPhone() async {
    String verificationId;
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      verificationId = verId;
      //print('code has been sent');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhoneVerify(
                    PhoneNumber: '+852' + phone,
                    verificationId: verificationId,
                    forceCodeResend: forceCodeResend,
                    email: email,
                    userName: name,
                    sex: sex,
                  )));
    };
    final PhoneVerificationCompleted verifySuccess = (AuthCredential user) {
      //print('verify');
    };
    final PhoneVerificationFailed verifyFail = (AuthException exception) {
      //print('${exception.message}');
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: yellow_color2,
        duration: Duration(seconds: 2),
        content: Text(
          exception.message,
          style: TextStyle(color: text_color1),
        ),
      ));
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+852' + phone,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(minutes: 1),
        verificationCompleted: verifySuccess,
        verificationFailed: verifyFail);
    return verificationId;
  }

  void onRegister() async {
    if (_formKey.currentState.validate()) {
      if (isPolicyChecked == false) {
        return;
      }
      FocusScope.of(context).unfocus();
      ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
        message: '登錄中...',
        backgroundColor: Theme.of(context).backgroundColor,
        messageTextStyle: TextStyle(
          color: getVisibleTextColorOnScaffold(context),
        ),
      );
      await pr.show();
      await Future.delayed(Duration(seconds: 1));
      try {
        var res = await isRegistered();
        if (res) {
          await pr.hide();
          _scaffoldKey.currentState.hideCurrentSnackBar();
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: yellow_color2,
            duration: Duration(seconds: 2),
            content: Text(
              '此電話號碼已存在。',
              style: TextStyle(color: text_color1),
            ),
          ));
          return;
        }
        await verifyPhone();
        await pr.hide();
      } catch (e) {
        await pr.hide();
        _scaffoldKey.currentState.hideCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
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

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : WillPopScope(
            onWillPop: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Wrapper()));
              return Future.value(false);
            },
            child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 35,
                        height: 35,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '註冊',
                        style: TextStyle(
                            color: text_color1,
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      )
                    ],
                  ),
                  actions: <Widget>[],
                ),
                body: Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 25.0),
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
                                    onChange: (val) {
                                      setState(() => name = val);
                                    }),
                                SizedBox(height: 20.0),
                                AuthInput(
                                    label: '電子郵件',
                                    type: 'email',
                                    onChange: (val) {
                                      setState(() => email = val);
                                    }),
                                SizedBox(height: 20.0),
                                AuthInput(
                                    label: '電話號碼',
                                    type: 'phone',
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
                                        curItem: sex,
                                        items: _sex,
                                        onChange: (newValue) {
                                          setState(() {
                                            sex = newValue;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              isPolicyChecked =
                                                  !isPolicyChecked;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: grey_color3,
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: grey_color2),
                                                child: isPolicyChecked
                                                    ? Icon(
                                                        Icons.check,
                                                        size: 18.0,
                                                        color: grey_color4,
                                                      )
                                                    : Icon(
                                                        null,
                                                        size: 18.0,
                                                      ),
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                '註冊”AA車”應用程式即表示您同意免責條款',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                              )
                                            ],
                                          )),
                                    ]),
                                SizedBox(height: 60.0),
                                MainBtn(
                                  label: '註冊',
                                  height: 64,
                                  onPress: () {
                                    onRegister();
                                  },
                                ),
                                SizedBox(height: 60.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '已經有賬號？',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: text_color3,
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          widget.toggleView(1);
                                        },
                                        child: Text(
                                          '請登入',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: text_color1,
                                          ),
                                        ))
                                  ],
                                ),
                                SizedBox(height: 20.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )),
          );
  }
}
