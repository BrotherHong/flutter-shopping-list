import 'package:flutter/material.dart';
import 'package:shopping_list/constants/my_color.dart';
import 'package:shopping_list/screens/item_list.dart';
import 'package:shopping_list/screens/person_list.dart';
import 'package:shopping_list/screens/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final screens = [
    const ItemListScreen(),
    const PersonListScreen(),
    const SettingScreen(),
  ];

  final screenTitle = ["購物清單", "購買人", "設定"];
  final screenIcon = [Icons.shopping_cart, Icons.people, Icons.settings];

  final pageController = PageController(initialPage: 1);

  int screenIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bulidAppBar(),
      bottomNavigationBar: buildBottomNavBar(),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children:screens,
        onPageChanged: (newIndex) {
          setState(() {
            screenIndex = newIndex;
          });
        },
      ),
    );
  }

  AppBar bulidAppBar() {
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            screenIcon[screenIndex],
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            screenTitle[screenIndex],
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar buildBottomNavBar() {
    return BottomNavigationBar(
      fixedColor: MyColor.main,
      unselectedItemColor: Colors.grey,
      currentIndex: screenIndex,
      items: List.generate(screens.length,
          (index) => buildBarItem(screenTitle[index], screenIcon[index])),
      onTap: (newIndex) {
        setState(() {
          pageController.animateToPage(
            newIndex,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
          );
        });
      },
    );
  }

  BottomNavigationBarItem buildBarItem(String label, IconData icon) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(icon),
      tooltip: label,
    );
  }
}
