import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/screens/settings.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/shared/loading.dart';
import 'package:shareacab/utils/constant.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/components/buttons.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  bool passwordHide = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  void initState() {
    passwordHide = true;
    super.initState();
  }

  void onSignIn() async {
    if (_formKey.currentState.validate()) {
      ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
        message: 'Signing in...',
        backgroundColor: Theme.of(context).backgroundColor,
        messageTextStyle: TextStyle(
          color: getVisibleTextColorOnScaffold(context),
        ),
      );
      await pr.show();
      await Future.delayed(Duration(seconds: 1));
      try {
        email = email.trim();
        var flag = await _auth.signInWithEmailAndPassword(email, password);
        if (flag == false) {
          error = 'ID not verified, verification mail sent again.';
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
        await pr.hide();
      } catch (e) {
        await pr.hide();
        if (mounted) {
          switch (e.code) {
            case 'ERROR_INVALID_EMAIL':
              error = 'Your email address appears to be malformed.';
              break;
            case 'ERROR_WRONG_PASSWORD':
              error = 'Your password is wrong.';
              break;
            case 'ERROR_USER_NOT_FOUND':
              error = "User with this email doesn't exist.";
              break;
            case 'ERROR_USER_DISABLED':
              error = 'User with this email has been disabled.';
              break;
            case 'ERROR_TOO_MANY_REQUESTS':
              error = 'Too many requests. Try again later.';
              break;
            case 'ERROR_OPERATION_NOT_ALLOWED':
              error = 'Signing in with Email and Password is not enabled.';
              break;
            default:
              {
                print('undefined error:' + error.toString());
                error = 'An undefined Error happened.';
              }
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

  void onForgotPass() {
    Navigator.pushNamed(context, '/accounts/forgotpass');
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
                'Sign in',
                style: TextStyle(color: text_color1),
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
                          SizedBox(height: 80.0),
                          MainBtn(
                            label: 'Sign in',
                            height: 64,
                            onPress: () {
                              onSignIn();
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    onForgotPass();
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: blue_color1,
                                    ),
                                  ))
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
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
                                    'Sign up',
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
