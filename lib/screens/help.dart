import 'package:flutter/material.dart';
import 'package:shareacab/main.dart';
import 'package:shareacab/utils/constant.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  List<Helper> helper = [
    Helper( 
        heading: '為什麼要使用「AA車」？',
        description:
            '主要目的是讓大家坐的士或Uber的時候可節省車資，慳錢、慳時間。',
        isExpanded: false),
    Helper( 
        heading: '如何使用「AA車」？',
        description:
            '簡單三步驟：組團、集合、出發。',
        isExpanded: false),
    Helper( 
        heading: '使用「AA車」是合法嗎？',
        description:
            '是合法的。「AA車」為去同一目的地的乘客先集合才出發，分擔車資。',
        isExpanded: false),
    Helper( 
        heading: '如果團友遲到怎樣辦？',
        description:
            '用戶建立群組是可選擇「準時出發」，即表示有權不等待遲到的團友下出發。',
        isExpanded: false),
    Helper( 
        heading: '如何與團友溝通？',
        description:
            '程式裡設有即時溝通功能，方便各團友即時溝通。',
        isExpanded: false),
    Helper( 
        heading: '怎樣為總車資？怎樣計算？',
        description:
            '群組裏所顯示的「目的地」為終點，各團友必須為「目的地」分擔車資。到達後如有其他地方要去，請個別團友自行處理。',
        isExpanded: false),
    Helper( 
        heading: '「AA車」如何處理用戶私隱？',
        description:
            '用戶資料如電話號碼等都不會公開或顯示。',
        isExpanded: false),
     
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellow_color2,
        leadingWidth: 32,
        leading: Container(
          padding: EdgeInsets.only(left: 6), 
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.chevron_left,
              color: text_color1,
              size: 32,
            ),
          ),
        ),
        titleSpacing: 8,
        title: Row(children: [
          // Image.asset(
          //   'assets/images/logo_full_qq.png',
          //   width: 160,
          //   height: 22,
          // ),
          Text('相關資料', style: TextStyle(color: text_color1, fontSize: 18, fontWeight: FontWeight.w500),),
        ]),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  helper[index].isExpanded = !helper[index].isExpanded;
                });
              },
              children: helper.map((Helper helper) {
                return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                        title: Text(
                      helper.heading,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: getVisibleColorOnScaffold(context),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ));
                  },
                  isExpanded: helper.isExpanded,
                  body: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 20.0),
                        child: Text(
                          helper.description,
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      // Container(
                      //     height:
                      //         helper.heading == 'Maximum number of Poolers' ||
                      //                 helper.heading ==
                      //                     'Require permission to join trip'
                      //             ? MediaQuery.of(context).size.height * 0.1
                      //             : MediaQuery.of(context).size.height * 0.6,
                      //     margin: EdgeInsets.all(13),
                      //     child: helper.thumbnail),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Helper {
  bool isExpanded;
  Image thumbnail;
  String heading;
  String description;

  Helper({this.heading, this.thumbnail, this.description, this.isExpanded});
}
