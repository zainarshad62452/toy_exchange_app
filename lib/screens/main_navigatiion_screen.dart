import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:toy_exchange_app/screens/post/my_post_screen.dart';
import 'package:toy_exchange_app/screens/profile_screen.dart';

import '../constants/colors.dart';
import 'category/category_list_screen.dart';
import 'chat/chat_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  static const screenId = 'main_nav_screen';
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  List<Widget> pages = [
    const HomeScreen(),
    const ChatScreen(),
    const CategoryListScreen(isForForm: true),
    const MyPostScreen(),
    const ProfileScreen(),
  ];
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: pages,
      ),
      bottomNavigationBar: DotNavigationBar(
        backgroundColor: Colors.black87,
        currentIndex: _currentIndex,
        onTap: _onTap,
        dotIndicatorColor: Colors.transparent,
        unselectedItemColor: disabledColor,
        enableFloatingNavBar: false,
        items: [
          DotNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _currentIndex == 0 ? secondaryColor : disabledColor,
            ),
          ),
          DotNavigationBarItem(
            icon: Icon(
              Icons.chat,
              color: _currentIndex == 1 ? secondaryColor : disabledColor,
            ),
          ),
          DotNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: _currentIndex == 2 ? secondaryColor : disabledColor,
            ),
          ),
          DotNavigationBarItem(
            icon: Icon(
              _currentIndex == 3 ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: _currentIndex == 3 ? secondaryColor : disabledColor,
            ),
          ),
          DotNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _currentIndex == 4 ? secondaryColor : disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
