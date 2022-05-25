import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shareacab/components/inputs.dart';
import 'package:shareacab/utils/constant.dart';

class FilterView extends StatefulWidget {
  String _curDeparture = '任何';
  String _curDestination = '任何';
  String _curDepartureSub = '任何';
  String _curDestinationSub = '任何';
  String _curGender = '任何';
  String _sortbyTime = '任何';
  final Function onChange;
  FilterView(
      this.onChange,
      this._curDeparture,
      this._curDepartureSub,
      this._curDestination,
      this._curDestinationSub,
      this._curGender,
      this._sortbyTime);
  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView>
    with AutomaticKeepAliveClientMixin<FilterView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String curDeparture = '任何';
  String curDestination = '任何';
  String curDepartureSub = '任何';
  String curDestinationSub = '任何';
  String curGender = '任何';
  String sortbyTime = '任何';

  String _departure;
  String _departure_sub;
  String _destination;
  String _destination_sub;

  @override
  void initState() {
    curDeparture = widget._curDeparture;
    curDestination = widget._curDestination;
    curDepartureSub = widget._curDepartureSub;
    curDestinationSub = widget._curDestinationSub;
    curGender = widget._curGender;
    sortbyTime = widget._sortbyTime;
    super.initState();
  }

  void showFilterDialog({bool isDestination = false}) async {
    var find_dest = location_filter1
        .firstWhere((element) => element == curDestination, orElse: () {
      return '任何';
    });
    var find_dest_sub = location_filter2[find_dest]
        .firstWhere((element) => element == curDestinationSub, orElse: () {
      return location_filter2[find_dest][0];
    });
    _destination_sub = find_dest_sub;
    _destination = find_dest;

    var find_departure = location_filter1
        .firstWhere((element) => element == curDeparture, orElse: () {
      return '任何';
    });
    var find_departure_sub = location_filter2[find_departure]
        .firstWhere((element) => element == curDepartureSub, orElse: () {
      return location_filter2[find_departure][0];
    });
    _departure_sub = find_departure_sub;
    _departure = find_departure;

    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
                height: 320,
                padding: const EdgeInsets.all(20.0),
                child: Column(children: <Widget>[
                  Text(
                    (isDestination ? '目的地' : '出發點'),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: text_color1),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  DropdownInput(
                    label: (isDestination ? '目的地 1' : '出發點 1'),
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: text_color1,
                        fontWeight: FontWeight.bold),
                    hint: '請選擇',
                    curItem: (isDestination ? _destination : _departure),
                    items: location_filter1,
                    onChange: (newValue) {
                      if (isDestination) {
                        setState(() {
                          _destination_sub = location_filter2[newValue][0];
                          _destination = newValue;
                        });
                      } else {
                        setState(() {
                          _departure_sub = location_filter2[newValue][0];
                          _departure = newValue;
                        });
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  DropdownInput(
                    label: (isDestination ? '目的地 2' : '出發點 2'),
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: text_color1,
                        fontWeight: FontWeight.bold),
                    hint: '請選擇',
                    curItem:
                        (isDestination ? _destination_sub : _departure_sub),
                    items: (isDestination
                        ? location_filter2[_destination]
                        : location_filter2[_departure]),
                    onChange: (newValue) {
                      if (isDestination) {
                        _destination_sub = newValue;
                      } else {
                        _departure_sub = newValue;
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      width: double.infinity,
                      child: FlatButton(
                        height: 50,
                        color: yellow_color1,
                        onPressed: () {
                          // setState(() {
                          //   curDeparture = _departure;
                          //   curDestination = _destination;
                          //   curDepartureSub = _departure_sub;
                          //   curDestinationSub = _destination_sub;
                          // });

                          widget.onChange(
                              _departure,
                              _departure_sub,
                              _destination,
                              _destination_sub,
                              curGender,
                              sortbyTime);
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                        },
                        child: Text('確認',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: text_color2)),
                      )),
                ])),
          );
        });
  }

  Widget filterBtn(List<String> items, String type) {
    var curValue = curGender;
    if (type == 'sortbytime') {
      curValue = sortbyTime;
    }
    return Container(
      child: DropdownButton<String>(
        value: curValue,
        icon: null,
        iconSize: 0,
        elevation: 16,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: text_color2),
        underline: Container(
          height: 0,
        ),
        onChanged: (String newValue) {
          if (type == 'sortbytime') {
            widget.onChange(curDeparture, curDepartureSub, curDestination,
                curDestinationSub, curGender, newValue);
          } else {
            widget.onChange(curDeparture, curDepartureSub, curDestination,
                curDestinationSub, newValue, sortbyTime);
          }
        },
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              width: MediaQuery.of(context).size.width / 4 - 20,
              // color: red_color1,
              child: Text(
                value,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.infinity,
      // height: 60,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
              child: InkWell(
            onTap: () {
              showFilterDialog(isDestination: false);
            },
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                Text('出發點'),
                SizedBox(
                  height: 13,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('$curDeparture - $curDepartureSub',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: text_color2)),
                ),
                SizedBox(
                  height: 12,
                ),
              ],
            ),
          )),
          Container(
            width: 20,
            child: SvgPicture.asset(
              'assets/svgs/vert_divider.svg',
            ),
          ),
          Expanded(
              child: InkWell(
                  onTap: () {
                    showFilterDialog(isDestination: true);
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Text('目的地'),
                      SizedBox(
                        height: 13,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('$curDestination - $curDestinationSub',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: text_color2)),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ))),
          Container(
            width: 20,
            child: SvgPicture.asset(
              'assets/svgs/vert_divider.svg',
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Text('團友性別'),
              filterBtn(['任何', '男女也可', '只限男性', '只限女性'], 'gender')
            ],
          ),
          Container(
            width: 20,
            child: SvgPicture.asset(
              'assets/svgs/vert_divider.svg',
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Text('出發時間'),
              filterBtn(['任何', '最早', '最遲'], 'sortbytime')
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
