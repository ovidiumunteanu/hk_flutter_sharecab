import 'package:flutter/material.dart';
import 'package:shareacab/utils/constant.dart';

class AuthInput extends StatelessWidget {
  final Function onChange;
  String label;
  String type;
  AuthInput({this.label, this.type, this.onChange});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: text_color2),
          ),
          SizedBox(
            height: 40,
            child: TextFormField(
              obscureText: type == 'pass',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: text_color1),
              decoration: InputDecoration(
                  // hintText: label,
                  ),
              validator: (val) => val.isEmpty ? 'Enter a valid data' : null,
              onChanged: (val) {
                onChange(val);
              },
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              color: grey_color1,
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownInput extends StatelessWidget {
  final Function onChange;
  String label;
  String hint;
  String curItem;
  List<String> items ;
  DropdownInput({this.label, this.hint , this.curItem, this.items, this.onChange});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: text_color2),
          ),
          SizedBox(
            height: 50,
            child: DropdownButtonFormField(
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: text_color1),
              decoration: InputDecoration(
                hintText: hint ?? 'Choose',
                hintStyle: TextStyle(fontSize: 14, color: grey_color1),
              ),
              value: curItem,
              onChanged: (newValue) {
                onChange(newValue);
              },
              items: items.map((temp) {
                return DropdownMenuItem(
                  value: temp,
                  child: Text(temp),
                );
              }).toList(),
            ),
          ),
          // Container(
          //   width: double.infinity,
          //   height: 1,
          //   decoration: BoxDecoration(
          //     color: grey_color1,
          //   ),
          // ),
        ],
      ),
    );
  }
}
