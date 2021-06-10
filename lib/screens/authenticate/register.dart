import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/shared/loading.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String confirmpass = '';
  String name = '';
  String mobileNum = '';
  String hostel;
  String sex;
  String error = '';
  String verify = '';

  final List<String> _sex = [
    'Female',
    'Male',
    'Others',
  ];

  final List<String> _hostels = [
    'Aravali',
    'Girnar',
    'Himadri',
    'Jwalamukhi',
    'Kailash',
    'Karakoram',
    'Kumaon',
    'Nilgiri',
    'Shivalik',
    'Satpura',
    'Udaigiri',
    'Vindhyachal',
    'Zanskar',
    'Day Scholar',
  ];

  bool passwordHide = false;
  bool isPolicyChecked = false;

  @override
  void initState() {
    passwordHide = true;
    super.initState();
  }

  void onRegister() async {
    if (_formKey.currentState.validate()) {
      if(isPolicyChecked == false) {
        return;
      }
      ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
        message: 'Signing up...',
        backgroundColor: Theme.of(context).backgroundColor,
        messageTextStyle: TextStyle(color: Theme.of(context).accentColor),
      );
      await pr.show();
      await Future.delayed(Duration(seconds: 1));
      try {
        await _auth.registerWithEmailAndPassword(
            email: email.trim(),
            password: password,
            name: name,
            // mobilenum: mobileNum,
            // hostel: hostel,
            sex: sex);

        verify =
            'Verification link has been sent to mailbox. Please verify and sign in.';
        await pr.hide();
      } catch (e) {
        await pr.hide();
        if (mounted) {
          switch (e.code) {
            case 'ERROR_WEAK_PASSWORD':
              error = 'Your password is too weak';
              break;
            case 'ERROR_INVALID_EMAIL':
              error = 'Your email is invalid';
              break;
            case 'ERROR_EMAIL_ALREADY_IN_USE':
              error = 'Email is already in use on different account';
              break;
            default:
              error = 'An undefined Error happened.';
          }
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            duration: Duration(seconds: 2),
            content: Text(
              error,
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
          ));
        }
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
                  title: Text(
                    'Sign up',
                    style: TextStyle(color: text_color1),
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
                                    label: 'Name',
                                    type: 'text',
                                    onChange: (val) {
                                      setState(() => name = val);
                                    }),
                                SizedBox(height: 20.0),
                                AuthInput(
                                    label: 'Email',
                                    type: 'email',
                                    onChange: (val) {
                                      setState(() => email = val);
                                    }),
                                SizedBox(height: 20.0),
                                AuthInput(
                                    label: 'Password',
                                    type: 'pass',
                                    onChange: (val) {
                                      setState(() => password = val);
                                    }),
                                SizedBox(height: 20.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: Dropdown(
                                        label: 'Gender',
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
                                SizedBox(height: 20,),
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
                                              SizedBox(width: 8,),
                                              Text(
                                                '參加此活動及同意此活動的免責條款',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                              )
                                            ],
                                          )),
                                    ]),
                                SizedBox(height: 80.0),
                                MainBtn(
                                  label: 'Create account now',
                                  height: 64,
                                  onPress: () {
                                    onRegister();
                                  },
                                ),
                                SizedBox(height: 100.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Have an account?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: text_color3,
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          widget.toggleView();
                                        },
                                        child: Text(
                                          'Log in',
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
