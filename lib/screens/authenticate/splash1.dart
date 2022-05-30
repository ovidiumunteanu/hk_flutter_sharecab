import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shareacab/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shareacab/screens/settings.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/shared/loading.dart';
import 'package:shareacab/utils/constant.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/components/buttons.dart';
import 'package:shareacab/utils/global.dart';

class Splash1 extends StatefulWidget {
  final Function toggleView;
  Splash1({this.toggleView});
  @override
  _Splash1State createState() => _Splash1State();
}

class _Splash1State extends State<Splash1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: yellow_color2,
            body: Builder(builder: (BuildContext context) {
              return Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 40.0),
                        Row(
                          children: [
                            Expanded(child: Container()),
                            TextButton(
                                onPressed: () {
                                  Global().isLoggedIn = false;
                                  Navigator.pushNamed(context, '/rootscreen');
                                },
                                child: Text(
                                  '略過',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: text_color1,
                                  ),
                                )),
                            SizedBox(
                              width: 20,
                            )
                          ],
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            child: Image.asset(
                              'assets/images/splash1.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 20.0),
                          Text(
                            'AA制車資',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: text_color1),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            '組團  -  集合  -  出發',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: text_color4),
                          ),
                          SizedBox(height: 24.0),
                          MainBtn(
                            label: '立即開始',
                            height: 64,
                            onPress: () {
                              widget.toggleView(1);
                            },
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '毋須任何費用',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: text_color4),
                          ),
                          SizedBox(height: 30.0),
                        ],
                      )),
                ],
              );
            }));
  }
}
