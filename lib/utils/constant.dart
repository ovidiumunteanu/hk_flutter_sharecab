import 'package:flutter/cupertino.dart';

Color yellow_color1 = const Color(0xFFFFD35C);
Color yellow_color2 = const Color(0xFFFDF6E0);

Color text_color1 = const Color(0xFF022541);
Color text_color2 = const Color(0xFF344655);
Color text_color3 = const Color(0xFF808C95);
Color text_color4 = const Color(0xFF292347);

Color red_color1 = const Color(0xFFFF0000);
Color red_color2 = const Color(0xFFDAA210);
Color red_color3 = const Color(0xFFFF5244);

Color grey_color1 = const Color(0xFFB3BABF);
Color grey_color2 = const Color(0xFFDCE3DE);
Color grey_color3 = const Color(0xFFA7BAAD);
Color grey_color4 = const Color(0xFF4F755B);
Color grey_color5 = const Color(0x99B3BABF);
Color grey_color6 = const Color(0xFFDDDDDD);
Color grey_color7 = const Color(0xFFF2F7F8);

Color blue_color1 = const Color(0xFF2F80ED);

int MAX_GROUP_MEMBERS = 4;

List<String> covid_list = ['必須已注射第一針', '必須已注射第二針', '必須已注射第三針'];


List<String> location_filter1 = ['任何', '香港島', '九龍', '新界', '離島'];
Map<String, List<String>> location_filter2 = {
  '任何' : ['任何'],
  '香港島': [
    '任何',
    '西環',
    '石塘咀',
    '西營盤',
    '堅尼地城',
    '上環',
    '中環',
    '半山',
    '山頂',
    '金鐘',
    '灣仔',
    '跑馬地',
    '銅鑼灣',
    '大坑',
    '天后',
    '北角',
    '鰂魚涌',
    '太古',
    '西灣河',
    '筲箕灣',
    '杏花邨',
    '柴灣',
    '薄扶林',
    '數碼港',
    '香港仔',
    '鴨脷洲',
    '深水灣',
    '黃竹坑',
    '淺水灣',
    '石澳',
    '赤柱'
  ],
  '九龍': [
    '任何',
    '美孚',
    '荔枝角',
    '長沙灣',
    '深水埗',
    '太子',
    '旺角',
    '大角咀',
    '油麻地',
    '佐敦',
    '尖沙咀',
    '紅磡',
    '何文田',
    '土瓜灣',
    '石硤尾',
    '九龍塘',
    '九龍城',
    '樂富',
    '黃大仙',
    '新蒲崗',
    '鑽石山',
    '慈雲山',
    '彩虹',
    '九龍灣',
    '牛頭角',
    '觀塘',
    '藍田',
    '油塘',
    '鯉魚門'
  ],
  '新界': [
    '任何',
    '大圍',
    '沙田',
    '火炭',
    '馬鞍山',
    '大埔',
    '太和',
    '粉嶺',
    '上水',
    '羅湖',
    '落馬洲',
    '葵芳',
    '葵涌',
    '荃灣',
    '青衣',
    '馬灣',
    '深井',
    '屯門',
    '元朗',
    '天水圍',
    '流浮山',
    '西貢',
    '將軍澳',
    '寶琳',
    '坑口'
  ],
  '離島': ['任何', '愉景灣', '東涌', '赤鱲角', '大嶼山', '大澳']
};


List<String> location_list1 = ['香港島', '九龍', '新界', '離島'];

Map<String, List<String>> location_list2 = {
  '香港島': [
    '西環',
    '石塘咀',
    '西營盤',
    '堅尼地城',
    '上環',
    '中環',
    '半山',
    '山頂',
    '金鐘',
    '灣仔',
    '跑馬地',
    '銅鑼灣',
    '大坑',
    '天后',
    '北角',
    '鰂魚涌',
    '太古',
    '西灣河',
    '筲箕灣',
    '杏花邨',
    '柴灣',
    '薄扶林',
    '數碼港',
    '香港仔',
    '鴨脷洲',
    '深水灣',
    '黃竹坑',
    '淺水灣',
    '石澳',
    '赤柱'
  ],
  '九龍': [
    '美孚',
    '荔枝角',
    '長沙灣',
    '深水埗',
    '太子',
    '旺角',
    '大角咀',
    '油麻地',
    '佐敦',
    '尖沙咀',
    '紅磡',
    '何文田',
    '土瓜灣',
    '石硤尾',
    '九龍塘',
    '九龍城',
    '樂富',
    '黃大仙',
    '新蒲崗',
    '鑽石山',
    '慈雲山',
    '彩虹',
    '九龍灣',
    '牛頭角',
    '觀塘',
    '藍田',
    '油塘',
    '鯉魚門'
  ],
  '新界': [
    '大圍',
    '沙田',
    '火炭',
    '馬鞍山',
    '大埔',
    '太和',
    '粉嶺',
    '上水',
    '羅湖',
    '落馬洲',
    '葵芳',
    '葵涌',
    '荃灣',
    '青衣',
    '馬灣',
    '深井',
    '屯門',
    '元朗',
    '天水圍',
    '流浮山',
    '西貢',
    '將軍澳',
    '寶琳',
    '坑口'
  ],
  '離島': ['愉景灣', '東涌', '赤鱲角', '大嶼山', '大澳']
};
