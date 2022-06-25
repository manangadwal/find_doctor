import 'package:find_doctor/screens/TabItems/chatScreen.dart';
import 'package:find_doctor/screens/TabItems/homeScreen.dart';
import 'package:find_doctor/screens/TabItems/settingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  User? user;
  HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int Curridx = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> tabItems = [
      HomeScreen(
        user: widget.user,
      ),
      ChatScreen(),
      AccountSettingScreen(
        user: widget.user,
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: tabItems[Curridx],
      bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: false,
          elevation: 0.0,
          currentIndex: Curridx,
          backgroundColor: Colors.transparent,
          showSelectedLabels: false,
          onTap: (idx) {
            print(widget.user?.uid);
            print(idx);
            setState(() {
              Curridx = idx;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: ""),
          ]),
    );
  }
}
