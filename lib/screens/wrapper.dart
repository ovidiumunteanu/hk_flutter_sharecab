import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shareacab/screens/authenticate/authenticate.dart';
import 'package:shareacab/utils/global.dart';
import 'rootscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'authenticate/verified_email_check.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return either home or Authenticate widget

    final user = Provider.of<FirebaseUser>(context);

    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Container(height: 200, child: Image(image: AssetImage('assets/images/logo.png'))),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          );
        } else {
          if (user == null) {
            Global().isLoggedIn = false;
            return Authenticate();
          } 
          // else if (user.isEmailVerified) {
          //   return RootScreen();
          // } 
          else {
            Global().isLoggedIn = true;
            // return VerificationCheck();
            return RootScreen();
          }
        }
      },
    );
  }
}
