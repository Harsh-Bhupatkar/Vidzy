import 'package:flutter/material.dart';
import 'package:vidzy_app/chat/chat_list_screen.dart';
import 'package:vidzy_app/meeting/history_meeting_screen.dart';
import 'package:vidzy_app/meeting/meeting_screen.dart';
import 'package:vidzy_app/screens/settings_screen.dart';
import 'package:vidzy_app/utils/colors.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  void onPageChanged(int value) {
    setState(() {
      _page = value;
    });
  }
  List<Widget> pages = [
    ChatListScreen(),
    MeetingScreen(),
    // HistoryMeetingScreen(),
    const SettingsScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meet & Chat"),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: pages[_page],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: footerColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          onTap: onPageChanged,
          currentIndex: _page,
          type: BottomNavigationBarType.fixed,
          unselectedFontSize: 14,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.comment_bank),
                label: "Meet & Chat"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.lock_clock),
                label: "Meetings"
            ),
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.history),
            //     label: "History"
            // ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: "Settings"
            ),
          ]
      ),
    );
  }


}
