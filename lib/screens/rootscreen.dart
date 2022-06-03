import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shareacab/screens/createtrip.dart';
import 'package:shareacab/screens/dashboard/dashboard.dart';
import 'package:shareacab/screens/groupchat.dart';
import 'package:shareacab/shared/guest.dart';
import 'package:shareacab/utils/global.dart';
import 'messages.dart';
import 'profile/userprofile.dart';
import 'notifications/notifications.dart';
import 'requests/myrequests.dart';
import 'package:shareacab/services/auth.dart';
import 'package:shareacab/shared/loading.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shareacab/utils/constant.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  bool loading = false;
  String error = '';
  Widget choose;

  // String _appBarTitle = '';
  bool justLoggedin = true;
  bool isHome = true;

  int _selectedPage = 0;

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
        title: Text(
          '路線',
          style: TextStyle(
              fontSize: 14,
              color: _selectedPage == 0 ? Colors.white : grey_color5),
        ),
        icon: Padding(
          padding: EdgeInsets.only(top: 4, bottom: 3),
          child: SvgPicture.asset(
            'assets/svgs/way.svg',
            color: _selectedPage == 0 ? Colors.white : grey_color5,
          ),
        ),
      ),
      BottomNavigationBarItem(
        title: Text(
          '開團',
          style: TextStyle(
              fontSize: 14,
              color: _selectedPage == 1 ? Colors.white : grey_color5),
        ),
        icon: SvgPicture.asset(
          'assets/svgs/plus.svg',
          color: _selectedPage == 1 ? Colors.white : grey_color5,
        ),
      ),
      BottomNavigationBarItem(
        title: Text(
          '已加入',
          style: TextStyle(
              fontSize: 14,
              color: _selectedPage == 2 ? Colors.white : grey_color5),
        ),
        icon: SvgPicture.asset(
          'assets/svgs/message.svg',
          color: _selectedPage == 2 ? Colors.white : grey_color5,
        ),
      ),
    ];
  }

  List<Widget> pagelist = <Widget>[];
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: pagelist,
    );
  }

  @override
  void initState() {
    pagelist.add(Dashboard());
    pagelist.add(CreateTrip(bottomTapped));
    pagelist.add(GroupChatScreen());
    // pagelist.add(Notifications());
    // pagelist.add(MyProfile(_auth));
    super.initState();
  }

  void pageChanged(int index) {
    if (Global().isLoggedIn != true && index > 0) {
      pageController.jumpToPage(0);
      GUEST_SERVICE.showGuestModal(context);
      return;
    }
    setState(() {
      _selectedPage = index;
    });
  }

  void bottomTapped(int index) {
    if (Global().isLoggedIn != true && index > 0) {
      GUEST_SERVICE.showGuestModal(context);
      return;
    }
    setState(() {
      _selectedPage = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            extendBody: true,
            body: buildPageView(),
            bottomNavigationBar: BottomNavigationBar(
              selectedFontSize: 14,
              unselectedFontSize: 14,
              onTap: (index) {
                bottomTapped(index);
              },
              items: buildBottomNavBarItems(),
              backgroundColor: text_color1,
            ),
          );
  }
}
