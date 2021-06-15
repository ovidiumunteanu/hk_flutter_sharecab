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

class Splash2 extends StatefulWidget {
  final Function toggleView;
  Splash2({this.toggleView});
  @override
  _Splash2State createState() => _Splash2State();
}

class _Splash2State extends State<Splash2> {
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  widget.toggleView(0);
                                },
                              ),
                              Image.asset(
                                'assets/images/logo_qq.png',
                                height: 80,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.0),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            child: Image.asset(
                              'assets/images/splash3.png',
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
                    'assets/images/splash4.png',
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
                            '簡單三步驟',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: text_color1),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            '一. 組團          二. 集合          三. 出發',
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
                                  ),
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: red_color3,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                  ),
                                ],
                              )),
                          SizedBox(height: 24.0),
                          MainBtn(
                            label: '立即體驗',
                            height: 64,
                            onPress: () {
                              widget.toggleView(2);
                            },
                          ),
                          SizedBox(height: 35.0),
                        ],
                      )),
                ],
              );
            }));
  }
}
