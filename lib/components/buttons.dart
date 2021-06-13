import 'package:flutter/material.dart';
import 'package:shareacab/utils/constant.dart';

class MainBtn extends StatelessWidget {
  final Function onPress;
  String label;
  Color textColor;
  double height = 0;
  MainBtn({this.label, this.textColor, this.height, this.onPress});
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints:
            BoxConstraints.tightFor(width: double.infinity, height: height),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(yellow_color1),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(height / 2),
              ))),
          onPressed: () => onPress(),
          child: Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: text_color2)),
        ));
  }
}
 