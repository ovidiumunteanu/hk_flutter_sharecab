import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/screens/settings.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/shared/loading.dart';
import 'package:shareacab/utils/constant.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/components/buttons.dart';

class PhoneVerify extends StatefulWidget {
  // final Function toggleView;
  String verificationId;
  String PhoneNumber;
  String userName;
  String email;
  String sex ;
  int forceCodeResend = -1;
  PhoneVerify(
      {this.PhoneNumber,
      this.verificationId,
      this.userName,
      this.email,
      this.sex,
      this.forceCodeResend});
  @override
  _PhoneVerifyState createState() => _PhoneVerifyState();
}

class _PhoneVerifyState extends State<PhoneVerify> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String verification_id;
  int forceResendToken;
  String code = '';

  @override
  void initState() {
    super.initState();
    verification_id = widget.verificationId;
    forceResendToken = widget.forceCodeResend;
  }

  void onResendCode() async {
    FocusScope.of(context).unfocus();
    ProgressDialog pr;
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: '重發代碼中...',
      backgroundColor: Theme.of(context).backgroundColor,
      messageTextStyle: TextStyle(
        color: getVisibleTextColorOnScaffold(context),
      ),
    );
    await pr.show();
    await Future.delayed(Duration(seconds: 1));
    try {
      await resendCode();
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

  Future<String> resendCode() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {};
    final PhoneVerificationCompleted verifySuccess = (AuthCredential user) {};
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      setState(() {
        verification_id = verId;
        forceResendToken = forceCodeResend;
      });
    };
    final PhoneVerificationFailed verifyFail = (AuthException exception) {
      //print('${exception.message}');
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: yellow_color2,
        duration: Duration(seconds: 2),
        content: Text(
          exception.message,
          style: TextStyle(color: text_color1),
        ),
      ));
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.PhoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        forceResendingToken: forceResendToken,
        codeSent: smsCodeSent,
        timeout: const Duration(minutes: 1),
        verificationCompleted: verifySuccess,
        verificationFailed: verifyFail);
    return '';
  }

  Future<String> verifyCode() async {
    final credential = PhoneAuthProvider.getCredential(
        verificationId: verification_id, smsCode: code);

    try {
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((AuthResult user) async {
        if (user != null) {
          print('correct code ' + user.user.uid);
          if (widget.userName == null) {
            //signin
            // get profile
            Navigator.pop(context);
          } else {
            // register
            await _auth.registerUser(
                userid: user.user.uid,
                email: widget.email,
                phone: widget.PhoneNumber,
                name: widget.userName,
                sex: widget.sex);
            Navigator.pop(context);
          }
        }
      });
    } catch (e) {
      print(e.toString());
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: yellow_color2,
        duration: Duration(seconds: 2),
        content: Text(
          '錯誤的驗證碼',
          style: TextStyle(color: text_color1),
        ),
      ));
    }
  }

  void onVerify() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
        message: '驗證中...',
        backgroundColor: Theme.of(context).backgroundColor,
        messageTextStyle: TextStyle(
          color: getVisibleTextColorOnScaffold(context),
        ),
      );
      await pr.show();
      await Future.delayed(Duration(seconds: 1));
      try {
        await verifyCode();
        await pr.hide();
      } catch (e) {
        await pr.hide();
        _scaffoldKey.currentState.hideCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          duration: Duration(seconds: 2),
          content: Text(
            e.toString(),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                '驗證電話號碼',
                style: TextStyle(color: text_color1),
              ),
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
            ),
            body: Builder(builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: 100.0),
                          AuthInput(
                              label: '驗證碼',
                              onChange: (val) {
                                setState(() => code = val);
                              }),
                          SizedBox(height: 80.0),
                          MainBtn(
                            label: '核實',
                            height: 64,
                            onPress: () {
                              onVerify();
                            },
                          ),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '沒有收到驗證碼？',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: text_color3,
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    onResendCode();
                                  },
                                  child: Text(
                                    '重發',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: text_color1,
                                    ),
                                  ))
                            ],
                          ),
                          SizedBox(height: 12.0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }));
  }
}
