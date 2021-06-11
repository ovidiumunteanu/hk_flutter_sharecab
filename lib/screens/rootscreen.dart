import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shareacab/screens/createtrip.dart';
import 'package:shareacab/screens/dashboard.dart';
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
        title: Container(),
        icon: SvgPicture.asset(
          'assets/svgs/way.svg',
          color: _selectedPage == 0 ? Colors.white : grey_color5,
        ),
      ),
      BottomNavigationBarItem(
        title: Container(),
        icon: SvgPicture.asset(
          'assets/svgs/plus.svg',
          color: _selectedPage == 1 ? Colors.white : grey_color5,
        ),
      ),
      BottomNavigationBarItem(
        title: Container(),
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
    pagelist.add(Messages());
    // pagelist.add(Notifications());
    // pagelist.add(MyProfile(_auth));
    super.initState();
  }

  void pageChanged(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  void bottomTapped(int index) {
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
              onTap: (index) {
                bottomTapped(index);
              },
              items: buildBottomNavBarItems(),
              backgroundColor: text_color1,
            ),
          );
  }
}
