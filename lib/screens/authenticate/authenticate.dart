import 'package:flutter/material.dart';
import 'package:shareacab/screens/authenticate/register.dart';
import 'package:shareacab/screens/authenticate/sign_in.dart';
import 'package:shareacab/screens/authenticate/splash1.dart';
import 'package:shareacab/screens/authenticate/splash2.dart';
import 'package:shareacab/screens/authenticate/phoneverify.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  int page = 0;

  void toggleView(page_index) {
    setState(() => page = page_index);
  }

  @override
  Widget build(BuildContext context) {
    if (page == 0) {
      return Splash1(toggleView: toggleView);
    } 
    else if (page == 1) {
      return Splash2(toggleView: toggleView);
    } 
    else if (page == 2) {
      return SignIn(toggleView: toggleView);
    } 
    else  {
      return Register(toggleView: toggleView);
    } 
  }
}
