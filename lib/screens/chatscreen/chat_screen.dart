import 'package:flutter/material.dart';
import 'package:shareacab/screens/chatscreen/chat_widgets/new_message.dart';
import 'package:shareacab/screens/chatscreen/chat_widgets/message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shareacab/services/trips.dart';
import 'package:shareacab/utils/constant.dart';

class ChatScreen extends StatefulWidget {
  final String docId;

  ChatScreen(this.docId);

  static const routeName = '/chatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //Set device token for current user
  final RequestService _request = RequestService();
  final FirebaseMessaging _fbm = FirebaseMessaging();
  Future<void> _getToken() async {
    await _fbm.getToken().then((token) {
      _request.setDeviceToken(token);
    });
  }

  @override
  void initState() {
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    _getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellow_color2,
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
        elevation: 0,
        title: Text(
          '聊天室',
          style: TextStyle(color: text_color1, fontSize: 18),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: MessageScreen(widget.docId),
            ),
            NewMessage(widget.docId),
          ],
        ),
      ),
    );
  }
}
