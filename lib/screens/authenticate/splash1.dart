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
                        Image.asset(
                          'assets/images/logo_car.png',
                          height: 65,
                        ),
                        SizedBox(height: 12.0),
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
                  Image.asset(
                    'assets/images/splash2.png',
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                  Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'AA制車資',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: text_color1),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            '「一個都半價」可慳錢、慳時間。',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: text_color4),
                          ),
                          SizedBox(height: 24.0),
                          Container(
                              width: 80,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: grey_color7,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: red_color3,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                  ),
                                  Container(
                                    width: 40,
                                  )
                                ],
                              )),
                          SizedBox(height: 24.0),
                          MainBtn(
                            label: '下一步',
                            height: 64,
                            onPress: () {
                              widget.toggleView(1);
                            },
                          ),
                          SizedBox(height: 90.0),
                        ],
                      )),
                ],
              );
            }));
  }
}
