import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class GUEST_SERVICE {
  static  void showGuestModal(context) async {
    try {
      await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog( 
              content: Text('抱歉，請閣下先登入，謝謝。'),
              actions: <Widget>[
                FlatButton(
                  child: Text('取消',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('登入',
                      style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () async { 
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/wrapper');
                  },
                ),
              ],
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }
}