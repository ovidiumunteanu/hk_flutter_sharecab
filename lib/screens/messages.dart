import 'package:flutter/material.dart';
import 'package:shareacab/screens/chatscreen/chat_widgets/chat_users_list.dart';
import 'package:shareacab/screens/rootscreen.dart';
import 'package:shareacab/screens/help.dart';
import 'package:shareacab/screens/settings.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth.dart';
import '../utils/constant.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  bool isSearching = false;
  final AuthService _auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void logout() async {
    ProgressDialog pr;
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
      message: '註銷...',
      backgroundColor: Theme.of(context).backgroundColor,
      messageTextStyle: TextStyle(color: Theme.of(context).accentColor),
    );
    await pr.show();
    await Future.delayed(Duration(
        seconds:
            1)); // sudden logout will show ProgressDialog for a very short time making it not very nice to see :p
    try {
      await _auth.signOut();
      await pr.hide();
    } catch (err) {
      await pr.hide();
      String errStr = err.message ?? err.toString();
      final snackBar =
          SnackBar(content: Text(errStr), duration: Duration(seconds: 3));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RootScreen()));
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: yellow_color2,
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 35,
                height: 40,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'AA制車資',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: text_color1),
              ),
            ],
          ),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(
            //     Icons.help,
            //     color: text_color1,
            //   ),
            //   tooltip: 'Help',
            //   onPressed: () {
            //     Navigator.push(
            //         context, MaterialPageRoute(builder: (context) => Help()));
            //   },
            // ),
            // IconButton(
            //     icon: Icon(
            //       Icons.settings,
            //       color: text_color1,
            //     ),
            //     tooltip: 'Settings',
            //     onPressed: () {
            //       return Navigator.push(context,
            //           MaterialPageRoute(builder: (context) {
            //         return Settings(_auth);
            //       }));
            //     }),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.userCircle,
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
                                    color: Theme.of(context).accentColor)),
                           
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('取消',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor)),
                            
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: yellow_color1,
                  ),
                  child: Center(
                    child: Text(
                      '「一個都半價」慳錢、慳時間。',
                      style: TextStyle(
                        fontSize: 14,
                        color: text_color4,
                      ),
                    ),
                  )),
              Expanded(
                child: ChatUsersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
